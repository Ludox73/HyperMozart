"use strict";

// ===== Panel loading =====
const PANEL_IDS = ['0','1','2','3','4','motif','5','6','iso'];

async function loadPanels() {
  let html = '';
  for (const id of PANEL_IDS) {
    const resp = await fetch('story/panels/step-' + id + '.html');
    if (resp.ok) html += await resp.text();
  }
  document.getElementById('story-panels').innerHTML = html;
}

// ===== Markdown loading =====
const mdFiles = [
  'story/01-introduction.md',
  'story/02-surface.md',
  'story/03-geodesic.md',
  'story/04-music.md',
  'story/05-distribution.md',
  'story/06-orthospectrum.md',
  'story/07-arcs.md'
];

function renderMd(container, text) {
  container.innerHTML = marked.parse(text);
  if (window.renderMathInElement) {
    renderMathInElement(container, {
      delimiters: [
        {left: '$$', right: '$$', display: true},
        {left: '$', right: '$', display: false}
      ],
      throwOnError: false
    });
  }
}

async function loadMarkdown() {
  for (let i = 0; i < mdFiles.length; i++) {
    const container = document.getElementById('content-' + i);
    if (!container) continue;
    let loaded = false;
    try {
      const resp = await fetch(mdFiles[i]);
      if (resp.ok) {
        const text = await resp.text();
        renderMd(container, text);
        loaded = true;
      }
    } catch (e) { /* fetch failed, use embedded fallback */ }
    if (!loaded) {
      const embedded = document.getElementById('md-' + i);
      if (embedded) {
        renderMd(container, embedded.textContent);
      }
    }
  }
}

// Wait for KaTeX to load, then render
function initMarkdown() {
  if (window.renderMathInElement) {
    loadMarkdown();
  } else {
    setTimeout(initMarkdown, 100);
  }
}

// ===== Step toggling =====
function toggleStep(n) {
  const el = document.getElementById('step-' + n);
  if (el.classList.contains('locked')) return;
  el.classList.toggle('open');
}

// ===== Step unlocking =====
let surfaceBuilt = false;
let geodesicDone = false;

function unlockStep(n) {
  const el = document.getElementById('step-' + n);
  el.classList.remove('locked');
  const badge = document.getElementById('lock-' + n);
  if (badge) badge.style.display = 'none';
}

function unlockGeodesicSteps() {
  geodesicDone = true;
  for (let i = 3; i <= 6; i++) unlockStep(i);
  unlockStep('motif');
  if (toMusic && toMusic.length > 0) {
    const minStr = motifMinInterval(toMusic).toFixed(4);
    document.getElementById('smotif2-min').textContent = minStr;
    document.getElementById('smotif3-min').textContent = minStr;
  }
  document.getElementById('step-3').classList.add('open');
}

// ===== UI wiring (slider display updates) =====
const sliderConfigs = {
  l1:  {display: 'v-l1',  fmt: v => v.toFixed(2)},
  l2:  {display: 'v-l2',  fmt: v => v.toFixed(2)},
  l3:  {display: 'v-l3',  fmt: v => v.toFixed(2)},
  t1:  {display: 'v-t1',  fmt: v => Math.round(v) + '%'},
  t2:  {display: 'v-t2',  fmt: v => Math.round(v) + '%'},
  t3:  {display: 'v-t3',  fmt: v => Math.round(v) + '%'},
  maxlen:     {display: 'v-maxlen',     fmt: v => maxlenFmt(v)},
  speed:      {display: 'v-speed',      fmt: v => v.toFixed(1)},
  audiospeed: {display: 'v-audiospeed', fmt: v => v.toFixed(1)},
  maxdur:     {display: 'v-maxdur',     fmt: v => Math.round(v).toString()},
};

// ===== Build Surface (step 1 action) =====
function buildSurface() {
  const p = getParams();
  const lengths = [p.l1, p.l2, p.l3];
  const gluingType = document.getElementById('gluing-type').value;
  const gluing = gluingType === 'nonseparating' ? createGluingNonseparatingS2() : createGluingSeparatingS2();
  const polytopes = buildPolytopes(gluing, lengths);

  const canvases = [0,1,2,3].map(i => document.getElementById('c' + i));
  drawHexagons(canvases, polytopes, gluing);

  surfaceBuilt = true;
  unlockStep(2);
  document.getElementById('step-2').classList.add('open');
}

// ===== Override finish to unlock steps =====
const _origFinish = finish;
finish = function() {
  _origFinish();
  if (toMusic && toMusic.length > 0) {
    unlockGeodesicSteps();
  }
};

// ===== Motif Frequency Estimation (step-motif) =====
function _motifResultsHtml(label, result, noteCount) {
  return `
    <div style="color:#c9a96e;font-weight:600;margin-bottom:8px">${label}</div>
    <table style="border-collapse:collapse;width:100%;font-family:monospace;font-size:.85rem">
      <tr style="color:#a0b8d0;border-bottom:1px solid #1e3060">
        <th style="text-align:left;padding:4px 8px">Metric</th>
        <th style="text-align:right;padding:4px 8px">Value</th>
      </tr>
      <tr style="color:#e8d5b7">
        <td style="padding:4px 8px">Total geodesic length</td>
        <td style="text-align:right;padding:4px 8px">${result.totalDist.toFixed(1)}</td>
      </tr>
      <tr style="color:#e8d5b7">
        <td style="padding:4px 8px">Note count</td>
        <td style="text-align:right;padding:4px 8px">${noteCount.toLocaleString()}</td>
      </tr>
      <tr style="color:#e8d5b7">
        <td style="padding:4px 8px">Motif count</td>
        <td style="text-align:right;padding:4px 8px">${result.count.toLocaleString()}</td>
      </tr>
      <tr style="color:#e8d5b7">
        <td style="padding:4px 8px">Frequency (per unit length)</td>
        <td style="text-align:right;padding:4px 8px">${result.freq.toExponential(4)}</td>
      </tr>
    </table>`;
}

function runStoryMotif2() {
  if (!toMusic || toMusic.length === 0) {
    document.getElementById('smotif2-status').textContent = 'No music data — run geodesic first.';
    return;
  }
  const a   = parseFloat(document.getElementById('smotif2-a').value);
  const eps = parseFloat(document.getElementById('smotif2-eps').value);
  document.getElementById('smotif2-status').textContent = 'Scanning…';
  const result = scanMotif2(toMusic, a, eps);
  document.getElementById('smotif2-status').textContent = 'Done.';
  const res = document.getElementById('smotif2-results');
  res.style.display = '';
  res.innerHTML = _motifResultsHtml(
    `2-Motif: a=${a.toFixed(2)}, ε=${eps.toFixed(3)}`, result, toMusic.length);
  document.getElementById('smotif2-plot-wrap').style.display = '';
  drawMotifFreqGraph('smotif2-canvas', [{ samples: result.samples, color: '#c9a96e' }]);
}

function runStoryMotif3() {
  if (!toMusic || toMusic.length === 0) {
    document.getElementById('smotif3-status').textContent = 'No music data — run geodesic first.';
    return;
  }
  const a   = parseFloat(document.getElementById('smotif3-a').value);
  const b   = parseFloat(document.getElementById('smotif3-b').value);
  const eps = parseFloat(document.getElementById('smotif3-eps').value);
  document.getElementById('smotif3-status').textContent = 'Scanning…';
  const result = scanMotif3(toMusic, a, b, eps);
  document.getElementById('smotif3-status').textContent = 'Done.';
  const res = document.getElementById('smotif3-results');
  res.style.display = '';
  res.innerHTML = _motifResultsHtml(
    `3-Motif: a=${a.toFixed(2)}, b=${b.toFixed(2)}, ε=${eps.toFixed(3)}`, result, toMusic.length);
  document.getElementById('smotif3-plot-wrap').style.display = '';
  drawMotifFreqGraph('smotif3-canvas', [{ samples: result.samples, color: '#ff7744' }]);
}

// ===== SVG zoom/pan for CDF chart =====
function trySetupSvgZoomPan() {
  const svg = document.getElementById('cdf-svg');
  if (svg && svg.getAttribute('viewBox')) {
    setupSvgZoomPan(svg);
  }
}

// ===== Arc filter perpendicular preset =====
function setArcFilterPerp() {
  const half = Math.PI / 2;
  const delta = 0.03;
  document.getElementById('arc-save-iamin').value = (half - delta).toFixed(2);
  document.getElementById('arc-save-iamax').value = (half + delta).toFixed(2);
  document.getElementById('arc-save-famin').value = (half - delta).toFixed(2);
  document.getElementById('arc-save-famax').value = (half + delta).toFixed(2);
}

// ===== Isomelodic Examples =====

const isoSliderConfigs = {
  'iso-speed':     {display: 'iso-v-speed',     fmt: v => v.toFixed(1)},
  'iso3-a':        {display: 'iso3-v-a',        fmt: v => v.toFixed(2)},
  'iso3-b':        {display: 'iso3-v-b',        fmt: v => v.toFixed(2)},
  'iso3-eps':      {display: 'iso3-v-eps',      fmt: v => v.toFixed(3)},
};

function toggleStepIso() {
  document.getElementById('step-iso').classList.toggle('open');
}

let isoStopRequested = false;
let isoSepMusic = null;
let isoNonMusic = null;
let isoAudioStop = {sep: false, non: false};
let iso2StopRequested = false;
let iso3StopRequested = false;

// ---- Partiture drawing ----
const CURVE_COLORS = ['#e44', '#4a4', '#44e'];

function drawPartiture(sepMusic, nonMusic, canvasId) {
  const canvas = document.getElementById(canvasId || 'iso-partiture');
  const ctx = canvas.getContext('2d');
  const W = canvas.width, H = canvas.height;
  ctx.clearRect(0, 0, W, H);

  function cumTimes(music) {
    const t = [];
    let acc = 0;
    for (const m of music) { acc += m[0]; t.push({time: acc, curve: m[1]}); }
    return t;
  }
  const sepT = cumTimes(sepMusic);
  const nonT = cumTimes(nonMusic);
  const maxTime = Math.max(
    sepT.length > 0 ? sepT[sepT.length - 1].time : 0,
    nonT.length > 0 ? nonT[nonT.length - 1].time : 0
  );
  if (maxTime === 0) return;

  const margin = 40;
  const plotW = W - margin - 10;
  const rowH = (H - 30) / 2;
  const sepY = 15;
  const nonY = sepY + rowH;

  ctx.fillStyle = '#c9a96e';
  ctx.font = '11px sans-serif';
  ctx.textAlign = 'right';
  ctx.fillText('Sep', margin - 6, sepY + rowH / 2 + 4);
  ctx.fillText('Non', margin - 6, nonY + rowH / 2 + 4);

  ctx.strokeStyle = '#0f3460';
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.moveTo(margin, nonY);
  ctx.lineTo(W - 10, nonY);
  ctx.stroke();

  function drawRow(events, y0, h) {
    for (const ev of events) {
      const x = margin + (ev.time / maxTime) * plotW;
      const color = CURVE_COLORS[ev.curve - 1] || '#fff';
      ctx.fillStyle = color;
      ctx.globalAlpha = 0.85;
      ctx.fillRect(x - 1, y0 + 4, 2, h - 8);
    }
    ctx.globalAlpha = 1.0;
  }
  drawRow(sepT, sepY, rowH);
  drawRow(nonT, nonY, rowH);
}

async function startIsomelodic() {
  isoStopRequested = false;
  isoSepMusic = null;
  isoNonMusic = null;

  document.getElementById('iso-btn-run').disabled = true;
  document.getElementById('iso-btn-stop').disabled = false;
  document.getElementById('iso-btn-play-sep').disabled = true;
  document.getElementById('iso-btn-play-non').disabled = true;
  document.getElementById('iso-sep-stats').textContent = '';
  document.getElementById('iso-non-stats').textContent = '';
  document.getElementById('iso-progress').style.width = '0%';
  document.getElementById('iso-status').textContent = 'Building surfaces...';

  const partCanvas = document.getElementById('iso-partiture');
  partCanvas.getContext('2d').clearRect(0, 0, partCanvas.width, partCanvas.height);

  const l1 = 5, l2 = 3, l3 = 3;
  const t1 = 0, t2 = 0, t3 = 0;
  const maxLen = 25;
  const drawSpeed = parseFloat(document.getElementById('iso-speed').value);
  const fastMode = document.getElementById('iso-fast-mode').checked;
  const lengths = [l1, l2, l3];
  const twists  = [t1, t2, t3];

  const sepGluing = createGluingSeparatingS2();
  const nonGluing = createGluingNonseparatingS2();
  const sepPolytopes = buildPolytopes(sepGluing, lengths);
  const nonPolytopes = buildPolytopes(nonGluing, lengths);
  const sepCircles = buildCircles(sepPolytopes);
  const nonCircles = buildCircles(nonPolytopes);

  const sepCanvases = [0,1,2,3].map(i => document.getElementById('iso-sep-c' + i));
  const nonCanvases = [0,1,2,3].map(i => document.getElementById('iso-non-c' + i));
  drawHexagons(sepCanvases, sepPolytopes, sepGluing);
  drawHexagons(nonCanvases, nonPolytopes, nonGluing);

  function initGeodesic(polytopes, a) {
    let bx = 0, by = 0;
    for (let k = 0; k < 6; k++) { bx += polytopes[0][k][0]; by += polytopes[0][k][1]; }
    bx /= 6; by /= 6;
    if (Math.abs(bx) < 1e-6 && Math.abs(by) < 1e-6) { bx += 1e-4; by += 1e-4; }
    const np2 = bx*bx + by*by;
    const tgScale = 20 * (2 / (1 - np2)) ** (-2);
    return { point: [bx, by], tgVec: [tgScale * Math.sin(a), tgScale * Math.cos(a)], polyIdx: 0, toAvoid: 6 };
  }

  const a = Math.random() * 2 * Math.PI;
  const sepState = initGeodesic(sepPolytopes, a);
  const nonState = initGeodesic(nonPolytopes, a);

  const sepCurves = sepGluing.curveCombinations.map((cc, i) => i === 0 ? cc : [[-1, -1]]);
  const nonCurves = nonGluing.curveCombinations.map((cc, i) => i === 0 ? cc : [[-1, -1]]);

  const sepMusic = [], nonMusic = [];
  let sepDist = 0, nonDist = 0;
  let sepSinceLast = 0, nonSinceLast = 0;
  let sepFirst = true, nonFirst = true;

  function applyPairingInstrumented(intersPoint, intersTgVec, poly, side, gluing, twists, polytopes) {
    const pr = pairingFromGluing(gluing, poly, side, twists, intersPoint, polytopes);
    let result = applyPoincarePointAndVector(pr.iso.poincare, intersPoint, intersTgVec);
    let newPoint = result.point, newTvec = result.tgVec;
    let reflectionError = null;

    if (isRow([poly, pr.outHex], gluing.noncoherentPairs)) {
      const toAvoidSide = pr.outSide;
      const index2 = (toAvoidSide + 1) % 6;
      const p1 = polytopes[pr.outHex][toAvoidSide];
      const p2 = polytopes[pr.outHex][index2];

      const z1p = [p1[0], p1[1]], z2p = [p2[0], p2[1]];
      const z1 = poincareToUpperHalf(z1p), z2 = poincareToUpperHalf(z2p);
      const x1 = z1[0], y1 = z1[1], x2 = z2[0], y2 = z2[1];
      const c_uh = (x1*x1 + y1*y1 - x2*x2 - y2*y2) / (2*(x1 - x2));
      const r_uh = Math.sqrt((x1 - c_uh)**2 + y1*y1);

      const Mreal = [[1, -(c_uh - r_uh)], [1, -(c_uh + r_uh)]];
      const J = [[-1, 0], [0, 1]];
      const Minv = mat2inv(Mreal);
      const JM = mat2mul(J, Mreal);
      const isoR = mat2mul(Minv, JM);
      const isoRc = isoR.map(r => r.map(v => [v, 0]));

      const np1c = [newPoint[0], newPoint[1]];
      const ntv1c = [newTvec[0], newTvec[1]];
      const np1uh = poincareToUpperHalf(np1c);
      const denom_uh = csub([1, 0], np1c);
      const deriv = cdiv([0, 2], cmul(denom_uh, denom_uh));
      const ntv1uh = cmul(deriv, ntv1c);

      const orResult = applyUpperHalfPointAndVectorOrientationReversing(isoRc, np1uh, ntv1uh);

      const backNp = cdiv(csub(orResult.point, [0, 1]), cadd(orResult.point, [0, 1]));
      const denomBack = cadd(orResult.point, [0, 1]);
      const backNtv = cmul(cdiv([0, 2], cmul(denomBack, denomBack)), orResult.tgVec);

      const pointDrift = Math.sqrt((backNp[0] - newPoint[0])**2 + (backNp[1] - newPoint[1])**2);
      const tvBefore = Math.sqrt(newTvec[0]**2 + newTvec[1]**2);
      const tvAfter = Math.sqrt(backNtv[0]**2 + backNtv[1]**2);
      const tvDx = backNtv[0] - newTvec[0], tvDy = backNtv[1] - newTvec[1];
      const tvAbsChange = Math.sqrt(tvDx*tvDx + tvDy*tvDy);
      const tvRelChange = tvBefore > 0 ? tvAbsChange / tvBefore : 0;

      reflectionError = {
        applied: true,
        fromHex: poly, fromSide: side,
        toHex: pr.outHex, toSide: pr.outSide,
        pointDrift,
        tvAbsChange,
        tvRelChange,
        tvBefore: [newTvec[0], newTvec[1]],
        tvAfter: [backNtv[0], backNtv[1]],
      };

      newTvec = [backNtv[0], backNtv[1]];
    }

    return { point: newPoint, tgVec: newTvec, polyIdx: pr.outHex, toAvoid: pr.outSide, reflectionError };
  }

  function stepOne(state, circles, gluing, polytopes, curves, music, dist, since, first) {
    const inter = firstIntersection(state.point, state.tgVec, circles[state.polyIdx], state.toAvoid);
    if (!inter) return null;
    const sp = [...state.point];
    const hexIdx = state.polyIdx;
    const side = inter.side;
    const dtp = distanceTwoPoints(state.point, inter.point);
    dist += dtp; since += dtp;
    const pr = applyPairingInstrumented(inter.point, inter.tgVec, state.polyIdx, inter.side, gluing, twists, polytopes);
    let curve = -1;
    for (let c = 0; c < 3; c++) {
      if (isRow([state.polyIdx, inter.side], curves[c])) { curve = c; break; }
    }
    if (curve >= 0) {
      if (!first) music.push([since, curve + 1]);
      since = 0; first = false;
    }
    state.point = pr.point; state.tgVec = pr.tgVec; state.polyIdx = pr.polyIdx; state.toAvoid = pr.toAvoid;
    return { dist, since, first, sp, ep: [...inter.point], hexIdx, side, dtp, curve, tgtHex: pr.polyIdx, tgtSide: pr.toAvoid, reflectionError: pr.reflectionError };
  }

  const symLog = [];
  const divergenceLog = [];
  let sepCrossingIdx = 0, nonCrossingIdx = 0;
  const sepStepLog = [];
  const nonStepLog = [];
  const syncPoints = [];
  let resyncInfo = null;
  let firstStructuralDivergence = null;
  const reflectionErrors = [];

  function _midAxGC(polyIdx, polytopes) {
    const V = polytopes[polyIdx];
    function hypMid(A, B) {
      const Az = [A[0], A[1]], Bz = [B[0], B[1]];
      const TB = cdiv(csub(Bz, Az), csub([1, 0], cmul(cconj(Az), Bz)));
      const r = Math.sqrt(TB[0]*TB[0] + TB[1]*TB[1]);
      if (r < 1e-15) return Az;
      const rm = Math.tanh(Math.atanh(r) / 2);
      const m0 = [TB[0]/r*rm, TB[1]/r*rm];
      return cdiv(cadd(m0, Az), cadd([1, 0], cmul(cconj(Az), m0)));
    }
    const M1 = hypMid(V[0], V[1]);
    const M3 = hypMid(V[3], V[4]);
    const gc = geodesicCircumferenceFromSegment(M1, M3);
    return { cx: gc.center[0], cy: gc.center[1], r2: gc.radius * gc.radius };
  }

  const GREY_AFTER = 2;
  const NUM_CHUNKS = 7;

  function createDrawState(canvases) {
    const baseImages = [];
    for (let h = 0; h < 4; h++) {
      const ctx = canvases[h].getContext('2d');
      baseImages.push(ctx.getImageData(0, 0, canvases[h].width, canvases[h].height));
    }
    return { canvases, baseImages, recentArcs: [] };
  }

  function drawRecentArcs(ds, skipLast) {
    for (let h = 0; h < 4; h++) {
      ds.canvases[h].getContext('2d').putImageData(ds.baseImages[h], 0, 0);
    }
    const drawCount = skipLast ? ds.recentArcs.length - 1 : ds.recentArcs.length;
    for (let i = 0; i < drawCount; i++) {
      const arc = ds.recentArcs[i];
      const cv = ds.canvases[arc.hexIdx];
      const ctx = cv.getContext('2d');
      const w = cv.width, ht = cv.height, cxC = w/2, cyC = ht/2, sc = w/2.3;
      const age = ds.recentArcs.length - 1 - i;
      if (age >= GREY_AFTER) {
        drawGeodesicSegment(ctx, cxC, cyC, sc, arc.sp, arc.ep, 'rgba(160,160,160,1.0)', 0.8);
      } else {
        drawGeodesicSegment(ctx, cxC, cyC, sc, arc.sp, arc.ep, 'rgba(255,80,80,0.85)', 1.5);
      }
    }
    const keep = GREY_AFTER + 2;
    if (ds.recentArcs.length > keep) {
      for (let i = 0; i < ds.recentArcs.length - keep; i++) {
        const arc = ds.recentArcs[i];
        const cv = ds.canvases[arc.hexIdx];
        const ctx = cv.getContext('2d');
        const w = cv.width, ht = cv.height, cxC = w/2, cyC = ht/2, sc = w/2.3;
        drawGeodesicSegment(ctx, cxC, cyC, sc, arc.sp, arc.ep, 'rgba(160,160,160,1.0)', 0.8);
      }
      for (let h = 0; h < 4; h++) {
        ds.baseImages[h] = ds.canvases[h].getContext('2d').getImageData(0, 0, ds.canvases[h].width, ds.canvases[h].height);
      }
      ds.recentArcs.splice(0, ds.recentArcs.length - keep);
    }
  }

  document.getElementById('iso-status').textContent = 'Running...';
  let step = 0;

  function checkDivergence(sepR, nonR, step) {
    if (!sepR || !nonR) return;

    if (sepR.reflectionError) {
      reflectionErrors.push({ step, which: 'sep', ...sepR.reflectionError });
    }
    if (nonR.reflectionError) {
      reflectionErrors.push({ step, which: 'non', ...nonR.reflectionError });
    }

    sepStepLog.push({ step, hex: sepR.hexIdx, side: sepR.side, dtp: sepR.dtp, tgtHex: sepR.tgtHex, tgtSide: sepR.tgtSide, curve: sepR.curve, refl: sepR.reflectionError });
    nonStepLog.push({ step, hex: nonR.hexIdx, side: nonR.side, dtp: nonR.dtp, tgtHex: nonR.tgtHex, tgtSide: nonR.tgtSide, curve: nonR.curve, refl: nonR.reflectionError });

    if (sepR.curve !== nonR.curve && !firstStructuralDivergence) {
      const lookback = Math.min(20, sepStepLog.length);
      const context = [];
      for (let i = sepStepLog.length - lookback; i < sepStepLog.length; i++) {
        if (i < 0) continue;
        const s = sepStepLog[i], n = nonStepLog[i];
        const dtpMatch = Math.abs(s.dtp - n.dtp) < 1e-6 ? '✓' : `✗ Δd=${Math.abs(s.dtp - n.dtp).toExponential(3)}`;
        const curveMatch = s.curve === n.curve ? '' : ` ◆CURVE MISMATCH sep=${s.curve} non=${n.curve}`;
        const reflInfo = [];
        if (s.refl) reflInfo.push(`sep:refl(ptΔ=${s.refl.pointDrift.toExponential(2)},tvΔ=${s.refl.tvRelChange.toExponential(2)})`);
        if (n.refl) reflInfo.push(`non:refl(ptΔ=${n.refl.pointDrift.toExponential(2)},tvΔ=${n.refl.tvRelChange.toExponential(2)})`);
        const reflStr = reflInfo.length > 0 ? ' ' + reflInfo.join(' ') : '';
        context.push(
          `  step ${s.step}: sep[hex${s.hex}→side${s.side}→hex${s.tgtHex} d=${s.dtp.toFixed(8)}]` +
          ` non[hex${n.hex}→side${n.side}→hex${n.tgtHex} d=${n.dtp.toFixed(8)}]` +
          ` ${dtpMatch}${curveMatch}${reflStr}`
        );
      }
      firstStructuralDivergence = {
        step,
        sepDist: sepR.dist,
        sepHex: sepR.hexIdx, sepSide: sepR.side, sepCurve: sepR.curve,
        nonHex: nonR.hexIdx, nonSide: nonR.side, nonCurve: nonR.curve,
        context: context.join('\n')
      };
    }

    const dtpDiff = Math.abs(sepR.dtp - nonR.dtp);
    if (dtpDiff > 1e-4 && divergenceLog.length < 20) {
      const lookback = Math.min(15, sepStepLog.length);
      const context = [];
      for (let i = sepStepLog.length - lookback; i < sepStepLog.length; i++) {
        if (i < 0) continue;
        const s = sepStepLog[i], n = nonStepLog[i];
        const match = Math.abs(s.dtp - n.dtp) < 1e-4;
        context.push(
          `  step ${s.step}: sep[hex${s.hex}→side${s.side}→hex${s.tgtHex} d=${s.dtp.toFixed(8)}]` +
          ` non[hex${n.hex}→side${n.side}→hex${n.tgtHex} d=${n.dtp.toFixed(8)}]` +
          ` ${match ? '✓' : '✗ Δ=' + Math.abs(s.dtp - n.dtp).toExponential(3)}`
        );
      }
      divergenceLog.push({
        step,
        sepDist: sepR.dist,
        sepHex: sepR.hexIdx, sepSide: sepR.side, sepDtp: sepR.dtp,
        nonHex: nonR.hexIdx, nonSide: nonR.side, nonDtp: nonR.dtp,
        diff: dtpDiff,
        context: context.join('\n')
      });
    }
  }

  if (fastMode) {
    // ===== FAST MODE =====
    while (sepDist < maxLen || nonDist < maxLen) {
      if (isoStopRequested) break;
      let sepR = null, nonR = null;
      if (sepDist < maxLen) {
        sepR = stepOne(sepState, sepCircles, sepGluing, sepPolytopes, sepCurves, sepMusic, sepDist, sepSinceLast, sepFirst);
        if (!sepR) break;
        sepDist = sepR.dist; sepSinceLast = sepR.since; sepFirst = sepR.first;
        if (sepR.curve === 0) {
          syncPoints.push({
            step,
            sepMusicIdx: sepMusic.length - 1,
            state: { point: [...sepState.point], tgVec: [...sepState.tgVec], polyIdx: sepState.polyIdx, toAvoid: sepState.toAvoid },
            dist: sepDist,
            sinceLast: 0,
          });
        }
      }
      if (nonDist < maxLen) {
        nonR = stepOne(nonState, nonCircles, nonGluing, nonPolytopes, nonCurves, nonMusic, nonDist, nonSinceLast, nonFirst);
        if (!nonR) break;
        nonDist = nonR.dist; nonSinceLast = nonR.since; nonFirst = nonR.first;
      }
      checkDivergence(sepR, nonR, step);
      if (sepR && nonR) {
        const P  = sepState.point,  VP = sepState.tgVec;
        const Q  = nonState.point,  VQ = nonState.tgVec;
        const ax = _midAxGC(nonState.polyIdx, nonPolytopes);
        const dx = Q[0]-ax.cx, dy = Q[1]-ax.cy, d2 = dx*dx+dy*dy;
        const Qp = [ax.cx + ax.r2*dx/d2, ax.cy + ax.r2*dy/d2];
        const dPQ  = distanceTwoPoints(P, Q);
        const dPQp = distanceTwoPoints(P, Qp);
        const ptSym = Math.min(dPQ, dPQp);
        const Qbest = dPQ <= dPQp ? Q : Qp;
        const rn = Math.sqrt(d2);
        const taux = -dy/rn, tauy = dx/rn;
        const VQn = Math.sqrt(VQ[0]*VQ[0]+VQ[1]*VQ[1]);
        const VQux = VQ[0]/VQn, VQuy = VQ[1]/VQn;
        const dot = VQux*taux + VQuy*tauy;
        const VQpx = 2*dot*taux - VQux, VQpy = 2*dot*tauy - VQuy;
        const VPn = Math.sqrt(VP[0]*VP[0]+VP[1]*VP[1]);
        const VPux = VP[0]/VPn, VPuy = VP[1]/VPn;
        const aPQ  = Math.acos(Math.max(-1, Math.min(1, VPux*VQux + VPuy*VQuy)));
        const aPQp = Math.acos(Math.max(-1, Math.min(1, VPux*VQpx + VPuy*VQpy)));
        const tgSym = Math.min(aPQ, aPQp);
        const VQbest = aPQ <= aPQp ? [VQux, VQuy] : [VQpx, VQpy];
        symLog.push({
          ptSym, tgSym,
          t: sepR.dist,
          P:   [P[0], P[1]],    VP:   [VPux, VPuy],
          Qb:  [Qbest[0], Qbest[1]],
          VQb: [VQbest[0], VQbest[1]],
          usedMirror: dPQ > dPQp,
          sepGluing: `hex${sepR.hexIdx}→side${sepR.side}→hex${sepR.tgtHex}(side${sepR.tgtSide})`,
          nonGluing: `hex${nonR.hexIdx}→side${nonR.side}→hex${nonR.tgtHex}(side${nonR.tgtSide})`,
        });
      }
      step++;
      if (step % 2000 === 0) {
        const pct = Math.min(100, Math.max(sepDist, nonDist) / maxLen * 100);
        document.getElementById('iso-progress').style.width = pct + '%';
        document.getElementById('iso-status').textContent = `Computing... ${Math.floor(pct)}%`;
        await new Promise(r => setTimeout(r, 0));
      }
    }

    // ===== RESYNC TEST =====
    if (firstStructuralDivergence && syncPoints.length > 0) {
      const divStep = firstStructuralDivergence.step;
      let lastSync = null;
      for (let i = syncPoints.length - 1; i >= 0; i--) {
        if (syncPoints[i].step < divStep) { lastSync = syncPoints[i]; break; }
      }
      if (lastSync) {
        document.getElementById('iso-status').textContent = 'Running resync test...';
        await new Promise(r => setTimeout(r, 0));

        const resyncState = {
          point: [...lastSync.state.point],
          tgVec: [...lastSync.state.tgVec],
          polyIdx: lastSync.state.polyIdx,
          toAvoid: lastSync.state.toAvoid,
        };
        const resyncSepState = {
          point: [...lastSync.state.point],
          tgVec: [...lastSync.state.tgVec],
          polyIdx: lastSync.state.polyIdx,
          toAvoid: lastSync.state.toAvoid,
        };

        const resyncLen = Math.min(maxLen / 2, 50000);
        const resyncSepMusic = [], resyncNonMusic = [];
        let rsD1 = 0, rsD2 = 0, rsS1 = 0, rsS2 = 0, rsF1 = true, rsF2 = true;
        const resyncStepLog = [];
        let resyncFirstDivStep = null;

        let rsStep = 0;
        while (rsD1 < resyncLen || rsD2 < resyncLen) {
          if (isoStopRequested) break;
          let r1 = null, r2 = null;
          if (rsD1 < resyncLen) {
            r1 = stepOne(resyncSepState, sepCircles, sepGluing, sepPolytopes, sepCurves, resyncSepMusic, rsD1, rsS1, rsF1);
            if (!r1) break;
            rsD1 = r1.dist; rsS1 = r1.since; rsF1 = r1.first;
          }
          if (rsD2 < resyncLen) {
            r2 = stepOne(resyncState, nonCircles, nonGluing, nonPolytopes, nonCurves, resyncNonMusic, rsD2, rsS2, rsF2);
            if (!r2) break;
            rsD2 = r2.dist; rsS2 = r2.since; rsF2 = r2.first;
          }
          if (r1 && r2) {
            const dtpDiff = Math.abs(r1.dtp - r2.dtp);
            const curveMismatch = r1.curve !== r2.curve;
            if (resyncStepLog.length < 200) {
              resyncStepLog.push({
                step: rsStep,
                sepHex: r1.hexIdx, sepSide: r1.side, sepDtp: r1.dtp, sepCurve: r1.curve,
                nonHex: r2.hexIdx, nonSide: r2.side, nonDtp: r2.dtp, nonCurve: r2.curve,
                dtpDiff, curveMismatch,
              });
            }
            if (curveMismatch && resyncFirstDivStep === null) {
              resyncFirstDivStep = rsStep;
            }
          }
          rsStep++;
          if (rsStep % 2000 === 0) await new Promise(r => setTimeout(r, 0));
        }

        let stepsInSync = 0;
        for (const e of resyncStepLog) {
          if (e.dtpDiff < 1e-4) stepsInSync++;
          else break;
        }

        resyncInfo = {
          syncStep: lastSync.step,
          syncDist: lastSync.dist,
          originalDivStep: divStep,
          resyncTotalSteps: rsStep,
          resyncStepsInSync: stepsInSync,
          resyncFirstDivStep,
          resyncSepCrossings: resyncSepMusic.length,
          resyncNonCrossings: resyncNonMusic.length,
          context: resyncStepLog.slice(0, 30).map(e =>
            `  step ${e.step}: sep[hex${e.sepHex}→side${e.sepSide} d=${e.sepDtp.toFixed(8)}]` +
            ` non[hex${e.nonHex}→side${e.nonSide} d=${e.nonDtp.toFixed(8)}]` +
            ` ${e.dtpDiff < 1e-6 ? '✓' : (e.dtpDiff < 1e-4 ? '~' : '✗')} Δ=${e.dtpDiff.toExponential(3)}` +
            `${e.curveMismatch ? ' ◆CURVE' : ''}`
          ).join('\n'),
          divContext: resyncFirstDivStep !== null ? resyncStepLog
            .filter(e => e.step >= resyncFirstDivStep - 10 && e.step <= resyncFirstDivStep + 5)
            .map(e =>
              `  step ${e.step}: sep[hex${e.sepHex}→side${e.sepSide} d=${e.sepDtp.toFixed(8)}]` +
              ` non[hex${e.nonHex}→side${e.nonSide} d=${e.nonDtp.toFixed(8)}]` +
              ` ${e.dtpDiff < 1e-6 ? '✓' : '✗'} Δ=${e.dtpDiff.toExponential(3)}` +
              `${e.curveMismatch ? ' ◆CURVE' : ''}`
            ).join('\n') : 'No divergence detected in resync run!',
        };
      }
    }
  } else {
    // ===== VISUAL MODE =====
    const sepDS = createDrawState(sepCanvases);
    const nonDS = createDrawState(nonCanvases);

    while (sepDist < maxLen || nonDist < maxLen) {
      if (isoStopRequested) break;

      let sepR = null, nonR = null;
      if (sepDist < maxLen) {
        sepR = stepOne(sepState, sepCircles, sepGluing, sepPolytopes, sepCurves, sepMusic, sepDist, sepSinceLast, sepFirst);
        if (!sepR) break;
        sepDist = sepR.dist; sepSinceLast = sepR.since; sepFirst = sepR.first;
        sepDS.recentArcs.push({ hexIdx: sepR.hexIdx, sp: sepR.sp, ep: sepR.ep });
      }
      if (nonDist < maxLen) {
        nonR = stepOne(nonState, nonCircles, nonGluing, nonPolytopes, nonCurves, nonMusic, nonDist, nonSinceLast, nonFirst);
        if (!nonR) break;
        nonDist = nonR.dist; nonSinceLast = nonR.since; nonFirst = nonR.first;
        nonDS.recentArcs.push({ hexIdx: nonR.hexIdx, sp: nonR.sp, ep: nonR.ep });
      }

      checkDivergence(sepR, nonR, step);

      drawRecentArcs(sepDS, true);
      drawRecentArcs(nonDS, true);

      const maxDtp = Math.max(sepR ? sepR.dtp : 0, nonR ? nonR.dtp : 0);
      const chunkPauseMs = Math.max(2, (maxDtp / drawSpeed) * 143);
      for (let ch = 0; ch < NUM_CHUNKS; ch++) {
        if (isoStopRequested) break;
        const f0 = ch / NUM_CHUNKS, f1 = (ch + 1) / NUM_CHUNKS;
        if (sepR) {
          const cv = sepCanvases[sepR.hexIdx];
          const ctx = cv.getContext('2d');
          drawGeodesicSegmentPartial(ctx, cv.width/2, cv.height/2, cv.width/2.3, sepR.sp, sepR.ep, 'rgba(255,80,80,0.85)', 1.5, f0, f1);
        }
        if (nonR) {
          const cv = nonCanvases[nonR.hexIdx];
          const ctx = cv.getContext('2d');
          drawGeodesicSegmentPartial(ctx, cv.width/2, cv.height/2, cv.width/2.3, nonR.sp, nonR.ep, 'rgba(255,80,80,0.85)', 1.5, f0, f1);
        }
        await new Promise(r => setTimeout(r, chunkPauseMs));
      }

      step++;
      if (step % 50 === 0 && (sepMusic.length > 0 || nonMusic.length > 0)) {
        drawPartiture(sepMusic, nonMusic);
      }

      const pct = Math.min(100, Math.max(sepDist, nonDist) / maxLen * 100);
      document.getElementById('iso-progress').style.width = pct + '%';
      document.getElementById('iso-status').textContent = `Running... ${Math.floor(pct)}% (Sep: ${sepMusic.length}, Non: ${nonMusic.length} crossings)`;
    }
  }

  isoSepMusic = sepMusic;
  isoNonMusic = nonMusic;
  document.getElementById('iso-progress').style.width = '100%';
  document.getElementById('iso-status').textContent = `Done.`;

  function statsHtml(music) {
    const total = music.length;
    const c1 = music.filter(x => x[1] === 1).length;
    const c2 = music.filter(x => x[1] === 2).length;
    const c3 = music.filter(x => x[1] === 3).length;
    return `Crossings: ${total} &nbsp;|&nbsp; C1: ${c1} &nbsp; C2: ${c2} &nbsp; C3: ${c3}`;
  }
  document.getElementById('iso-sep-stats').innerHTML = statsHtml(sepMusic);
  document.getElementById('iso-non-stats').innerHTML = statsHtml(nonMusic);

  drawPartiture(sepMusic, nonMusic);

  if (sepMusic.length > 1) {
    let minInterval = Infinity;
    for (const note of sepMusic) minInterval = Math.min(minInterval, note[0]);
    const el = document.getElementById('iso3-min-interval');
    if (el) el.textContent = minInterval.toFixed(4);
  }

  document.getElementById('iso-btn-run').disabled = false;
  document.getElementById('iso-btn-stop').disabled = true;
  if (sepMusic.length > 0) document.getElementById('iso-btn-play-sep').disabled = false;
  if (nonMusic.length > 0) document.getElementById('iso-btn-play-non').disabled = false;
}

// ===== Shared helpers for iso2 and iso3 =====

function _buildIsoSurfaces(l1, l2, l3, t1, t2, t3) {
  const lengths = [l1, l2, l3], twists = [t1, t2, t3];
  const sepGluing = createGluingSeparatingS2();
  const nonGluing = createGluingNonseparatingS2();
  const sepPolytopes = buildPolytopes(sepGluing, lengths);
  const nonPolytopes = buildPolytopes(nonGluing, lengths);
  const sepCircles = buildCircles(sepPolytopes);
  const nonCircles = buildCircles(nonPolytopes);
  return { sepGluing, nonGluing, sepPolytopes, nonPolytopes, sepCircles, nonCircles, twists };
}

function _initGeodesic(polytopes, a) {
  let bx = 0, by = 0;
  for (let k = 0; k < 6; k++) { bx += polytopes[0][k][0]; by += polytopes[0][k][1]; }
  bx /= 6; by /= 6;
  if (Math.abs(bx) < 1e-6 && Math.abs(by) < 1e-6) { bx += 1e-4; by += 1e-4; }
  const np2 = bx*bx + by*by;
  const tgScale = 20 * (2 / (1 - np2)) ** (-2);
  return { point: [bx, by], tgVec: [tgScale * Math.sin(a), tgScale * Math.cos(a)], polyIdx: 0, toAvoid: 6 };
}

function _applyPairingInstr(intersPoint, intersTgVec, poly, side, gluing, twists, polytopes) {
  const pr = pairingFromGluing(gluing, poly, side, twists, intersPoint, polytopes);
  let result = applyPoincarePointAndVector(pr.iso.poincare, intersPoint, intersTgVec);
  let newPoint = result.point, newTvec = result.tgVec;
  if (isRow([poly, pr.outHex], gluing.noncoherentPairs)) {
    const toAvoidSide = pr.outSide;
    const index2 = (toAvoidSide + 1) % 6;
    const p1 = polytopes[pr.outHex][toAvoidSide];
    const p2 = polytopes[pr.outHex][index2];
    const z1p = [p1[0], p1[1]], z2p = [p2[0], p2[1]];
    const z1 = poincareToUpperHalf(z1p), z2 = poincareToUpperHalf(z2p);
    const x1 = z1[0], y1 = z1[1], x2 = z2[0], y2 = z2[1];
    const c_uh = (x1*x1 + y1*y1 - x2*x2 - y2*y2) / (2*(x1 - x2));
    const r_uh = Math.sqrt((x1 - c_uh)**2 + y1*y1);
    const Mreal = [[1, -(c_uh - r_uh)], [1, -(c_uh + r_uh)]];
    const J = [[-1, 0], [0, 1]];
    const Minv = mat2inv(Mreal);
    const isoR = mat2mul(Minv, mat2mul(J, Mreal));
    const isoRc = isoR.map(r => r.map(v => [v, 0]));
    const np1c = [newPoint[0], newPoint[1]];
    const ntv1c = [newTvec[0], newTvec[1]];
    const np1uh = poincareToUpperHalf(np1c);
    const denom_uh = csub([1, 0], np1c);
    const deriv = cdiv([0, 2], cmul(denom_uh, denom_uh));
    const ntv1uh = cmul(deriv, ntv1c);
    const orResult = applyUpperHalfPointAndVectorOrientationReversing(isoRc, np1uh, ntv1uh);
    const backNp = cdiv(csub(orResult.point, [0, 1]), cadd(orResult.point, [0, 1]));
    const denomBack = cadd(orResult.point, [0, 1]);
    const backNtv = cmul(cdiv([0, 2], cmul(denomBack, denomBack)), orResult.tgVec);
    newTvec = [backNtv[0], backNtv[1]];
  }
  return { point: newPoint, tgVec: newTvec, polyIdx: pr.outHex, toAvoid: pr.outSide };
}

function _stepOne(state, circles, gluing, polytopes, curves, music, dist, since, first, twists) {
  const inter = firstIntersection(state.point, state.tgVec, circles[state.polyIdx], state.toAvoid);
  if (!inter) return null;
  const sp = [...state.point];
  const hexIdx = state.polyIdx;
  const side = inter.side;
  const dtp = distanceTwoPoints(state.point, inter.point);
  dist += dtp; since += dtp;
  const pr = _applyPairingInstr(inter.point, inter.tgVec, state.polyIdx, inter.side, gluing, twists, polytopes);
  let curve = -1;
  for (let c = 0; c < 3; c++) {
    if (isRow([state.polyIdx, inter.side], curves[c])) { curve = c; break; }
  }
  if (curve >= 0) {
    if (!first) music.push([since, curve + 1]);
    since = 0; first = false;
  }
  state.point = pr.point; state.tgVec = pr.tgVec; state.polyIdx = pr.polyIdx; state.toAvoid = pr.toAvoid;
  return { dist, since, first, sp, ep: [...inter.point], hexIdx, side, dtp, curve, tgtHex: pr.polyIdx, tgtSide: pr.toAvoid };
}

function _midAxGCShared(polyIdx, polytopes) {
  const V = polytopes[polyIdx];
  function hypMid(A, B) {
    const Az = [A[0], A[1]], Bz = [B[0], B[1]];
    const TB = cdiv(csub(Bz, Az), csub([1, 0], cmul(cconj(Az), Bz)));
    const r = Math.sqrt(TB[0]*TB[0] + TB[1]*TB[1]);
    if (r < 1e-15) return Az;
    const rm = Math.tanh(Math.atanh(r) / 2);
    const m0 = [TB[0]/r*rm, TB[1]/r*rm];
    return cdiv(cadd(m0, Az), cadd([1, 0], cmul(cconj(Az), m0)));
  }
  const M1 = hypMid(V[0], V[1]);
  const M3 = hypMid(V[3], V[4]);
  const gc = geodesicCircumferenceFromSegment(M1, M3);
  return { cx: gc.center[0], cy: gc.center[1], r2: gc.radius * gc.radius };
}

// ===== LOG-SCALE PLOT for Part 2 =====
function _drawLogPlot(canvasId, data, tMax, color, xLabel, yLabel) {
  const cv = document.getElementById(canvasId);
  if (!cv) return;
  const W = cv.width, H = cv.height;
  const ctx = cv.getContext('2d');
  ctx.clearRect(0, 0, W, H);
  ctx.fillStyle = '#0a0a1a';
  ctx.fillRect(0, 0, W, H);

  const PAD_L = 64, PAD_R = 12, PAD_T = 12, PAD_B = 32;
  const plotW = W - PAD_L - PAD_R;
  const plotH = H - PAD_T - PAD_B;

  const pts = data.filter(e => e.t <= tMax && e.v > 0);

  let yMin = -16, yMax = 1;
  if (pts.length > 0) {
    const logVals = pts.map(e => Math.log10(e.v));
    const dataMin = Math.min(...logVals), dataMax = Math.max(...logVals);
    yMin = Math.floor(dataMin) - 1;
    yMax = Math.ceil(dataMax) + 1;
    if (yMax - yMin < 4) { yMin = dataMin - 1; yMax = dataMax + 1; }
  }
  const yRange = yMax - yMin;

  function toX(t)  { return PAD_L + (t / tMax) * plotW; }
  function toY(lv) { return PAD_T + plotH - ((lv - yMin) / yRange) * plotH; }

  ctx.strokeStyle = '#1e2e4a';
  ctx.lineWidth = 1;
  ctx.fillStyle = '#778899';
  ctx.font = '10px monospace';
  ctx.textAlign = 'right';
  for (let e = Math.ceil(yMin); e <= Math.floor(yMax); e++) {
    const y = toY(e);
    if (y < PAD_T || y > PAD_T + plotH) continue;
    ctx.beginPath(); ctx.moveTo(PAD_L, y); ctx.lineTo(PAD_L + plotW, y); ctx.stroke();
    ctx.fillText(`1e${e}`, PAD_L - 4, y + 3);
  }
  ctx.textAlign = 'center';
  const xStep = tMax <= 50 ? 5 : 10;
  for (let t = 0; t <= tMax; t += xStep) {
    const x = toX(t);
    ctx.beginPath(); ctx.moveTo(x, PAD_T); ctx.lineTo(x, PAD_T + plotH); ctx.stroke();
    ctx.fillText(t, x, PAD_T + plotH + 14);
  }
  ctx.strokeStyle = '#4466aa';
  ctx.lineWidth = 1.5;
  ctx.beginPath();
  ctx.moveTo(PAD_L, PAD_T); ctx.lineTo(PAD_L, PAD_T + plotH);
  ctx.lineTo(PAD_L + plotW, PAD_T + plotH);
  ctx.stroke();
  ctx.fillStyle = '#a0b8d0';
  ctx.font = '11px monospace';
  ctx.textAlign = 'center';
  ctx.fillText(xLabel, PAD_L + plotW / 2, H - 4);
  ctx.save();
  ctx.translate(12, PAD_T + plotH / 2);
  ctx.rotate(-Math.PI / 2);
  ctx.fillText(yLabel, 0, 0);
  ctx.restore();
  if (pts.length === 0) return;
  ctx.strokeStyle = color;
  ctx.lineWidth = 1.2;
  ctx.beginPath();
  let started = false;
  for (const e of pts) {
    const lv = Math.log10(e.v);
    if (lv < yMin || lv > yMax) { started = false; continue; }
    const x = toX(e.t), y = toY(lv);
    if (!started) { ctx.moveTo(x, y); started = true; } else { ctx.lineTo(x, y); }
  }
  ctx.stroke();
}

// ===== PART 2: startIsomelodic2 =====
async function startIsomelodic2() {
  iso2StopRequested = false;
  const l1 = 5, l2 = 3, l3 = 3, t1 = 0, t2 = 0, t3 = 0;
  const maxLen = 50;
  const twists = [t1, t2, t3];

  document.getElementById('iso2-btn-run').disabled = true;
  document.getElementById('iso2-btn-stop').disabled = false;
  document.getElementById('iso2-progress').style.width = '0%';
  document.getElementById('iso2-status').textContent = 'Building surfaces...';

  const partCanvas2 = document.getElementById('iso2-partiture');
  partCanvas2.getContext('2d').clearRect(0, 0, partCanvas2.width, partCanvas2.height);

  const { sepGluing, nonGluing, sepPolytopes, nonPolytopes, sepCircles, nonCircles } =
    _buildIsoSurfaces(l1, l2, l3, t1, t2, t3);

  const sepCanvases2 = [0,1,2,3].map(i => document.getElementById('iso2-sep-c' + i));
  const nonCanvases2 = [0,1,2,3].map(i => document.getElementById('iso2-non-c' + i));
  drawHexagons(sepCanvases2, sepPolytopes, sepGluing);
  drawHexagons(nonCanvases2, nonPolytopes, nonGluing);

  const a = Math.random() * 2 * Math.PI;
  const sepState = _initGeodesic(sepPolytopes, a);
  const nonState = _initGeodesic(nonPolytopes, a);

  const sepCurves = sepGluing.curveCombinations.map((cc, i) => i === 0 ? cc : [[-1, -1]]);
  const nonCurves = nonGluing.curveCombinations.map((cc, i) => i === 0 ? cc : [[-1, -1]]);

  const sepMusic = [], nonMusic = [];
  let sepDist = 0, nonDist = 0;
  let sepSinceLast = 0, nonSinceLast = 0;
  let sepFirst = true, nonFirst = true;

  const symLog2 = [];

  document.getElementById('iso2-status').textContent = 'Running...';

  let step = 0;
  while (sepDist < maxLen || nonDist < maxLen) {
    if (iso2StopRequested) break;
    let sepR = null, nonR = null;
    if (sepDist < maxLen) {
      sepR = _stepOne(sepState, sepCircles, sepGluing, sepPolytopes, sepCurves, sepMusic, sepDist, sepSinceLast, sepFirst, twists);
      if (!sepR) break;
      sepDist = sepR.dist; sepSinceLast = sepR.since; sepFirst = sepR.first;
    }
    if (nonDist < maxLen) {
      nonR = _stepOne(nonState, nonCircles, nonGluing, nonPolytopes, nonCurves, nonMusic, nonDist, nonSinceLast, nonFirst, twists);
      if (!nonR) break;
      nonDist = nonR.dist; nonSinceLast = nonR.since; nonFirst = nonR.first;
    }
    if (sepR && nonR) {
      const P = sepState.point, Q = nonState.point;
      const ax = _midAxGCShared(nonState.polyIdx, nonPolytopes);
      const dx = Q[0]-ax.cx, dy = Q[1]-ax.cy, d2 = dx*dx+dy*dy;
      const Qp = [ax.cx + ax.r2*dx/d2, ax.cy + ax.r2*dy/d2];
      const dPQ = distanceTwoPoints(P, Q);
      const dPQp = distanceTwoPoints(P, Qp);
      symLog2.push({ t: sepR.dist, v: Math.min(dPQ, dPQp) });
    }
    step++;
    if (step % 2000 === 0) {
      const pct = Math.min(100, Math.max(sepDist, nonDist) / maxLen * 100);
      document.getElementById('iso2-progress').style.width = pct + '%';
      document.getElementById('iso2-status').textContent = `Computing... ${Math.floor(pct)}%`;
      await new Promise(r => setTimeout(r, 0));
    }
  }

  document.getElementById('iso2-progress').style.width = '100%';
  document.getElementById('iso2-status').textContent = 'Done.';
  drawPartiture(sepMusic, nonMusic, 'iso2-partiture');
  _drawLogPlot('iso2-plot-pt', symLog2, 50, '#ff7744', 't (hyperbolic length)', 'pt error');

  document.getElementById('iso2-btn-run').disabled = false;
  document.getElementById('iso2-btn-stop').disabled = true;
}

// ===== PART 3: runMotifAnalysis =====
async function runMotifAnalysis() {
  iso3StopRequested = false;
  const a   = parseFloat(document.getElementById('iso3-a').value);
  const b   = parseFloat(document.getElementById('iso3-b').value);
  const eps = parseFloat(document.getElementById('iso3-eps').value);
  const maxLen = parseFloat(document.getElementById('iso3-maxlen').value);

  document.getElementById('iso3-btn-run').disabled = true;
  document.getElementById('iso3-btn-stop').disabled = false;
  document.getElementById('iso3-progress').style.width = '0%';
  document.getElementById('iso3-status').textContent = 'Building surfaces...';
  document.getElementById('iso3-results').style.display = 'none';
  document.getElementById('iso3-plot-wrap').style.display = 'none';

  const l1 = 5, l2 = 3, l3 = 3, t1 = 0, t2 = 0, t3 = 0;
  const twists = [t1, t2, t3];

  const { sepGluing, nonGluing, sepPolytopes, nonPolytopes, sepCircles, nonCircles } =
    _buildIsoSurfaces(l1, l2, l3, t1, t2, t3);

  const ang = Math.random() * 2 * Math.PI;
  const sepState = _initGeodesic(sepPolytopes, ang);
  const nonState = _initGeodesic(nonPolytopes, ang);

  const sepCurves = sepGluing.curveCombinations.map((cc, i) => i === 0 ? cc : [[-1, -1]]);
  const nonCurves = nonGluing.curveCombinations.map((cc, i) => i === 0 ? cc : [[-1, -1]]);

  document.getElementById('iso3-status').textContent = 'Running geodesics...';

  const sepMusic = [], nonMusic = [];
  let sepDist = 0, nonDist = 0;
  let sepSinceLast = 0, nonSinceLast = 0;
  let sepFirst = true, nonFirst = true;
  let sepMotifs = 0, nonMotifs = 0;

  const sampleInterval = Math.max(100, maxLen / 500);
  let nextSample = sampleInterval;
  const freqSamples = [];

  function checkMotif(music) {
    const k = music.length - 1;
    if (k < 2) return false;
    const d12 = music[k-1][0], d23 = music[k][0];
    return d12 >= a && d12 <= a + eps && d12 + d23 >= a + b && d12 + d23 <= a + b + eps;
  }

  let step = 0;
  while (sepDist < maxLen || nonDist < maxLen) {
    if (iso3StopRequested) break;

    if (sepDist < maxLen) {
      const prevLen = sepMusic.length;
      const r = _stepOne(sepState, sepCircles, sepGluing, sepPolytopes, sepCurves, sepMusic, sepDist, sepSinceLast, sepFirst, twists);
      if (!r) break;
      sepDist = r.dist; sepSinceLast = r.since; sepFirst = r.first;
      if (sepMusic.length > prevLen && checkMotif(sepMusic)) sepMotifs++;
    }

    if (nonDist < maxLen) {
      const prevLen = nonMusic.length;
      const r = _stepOne(nonState, nonCircles, nonGluing, nonPolytopes, nonCurves, nonMusic, nonDist, nonSinceLast, nonFirst, twists);
      if (!r) break;
      nonDist = r.dist; nonSinceLast = r.since; nonFirst = r.first;
      if (nonMusic.length > prevLen && checkMotif(nonMusic)) nonMotifs++;
    }

    const tNow = Math.min(sepDist, nonDist);
    if (tNow >= nextSample) {
      freqSamples.push({
        t: tNow,
        sepFreq: sepDist > 0 ? sepMotifs / sepDist : 0,
        nonFreq: nonDist > 0 ? nonMotifs / nonDist : 0,
      });
      nextSample += sampleInterval;
    }

    step++;
    if (step % 50000 === 0) {
      const pct = Math.min(100, Math.max(sepDist, nonDist) / maxLen * 100);
      document.getElementById('iso3-progress').style.width = pct + '%';
      document.getElementById('iso3-status').textContent =
        `Computing... ${Math.floor(pct)}%  (sep: ${sepMotifs} motifs / ${sepDist.toFixed(0)} len,  non: ${nonMotifs} motifs / ${nonDist.toFixed(0)} len)`;
      await new Promise(r => setTimeout(r, 0));
    }
  }

  freqSamples.push({
    t: Math.min(sepDist, nonDist),
    sepFreq: sepDist > 0 ? sepMotifs / sepDist : 0,
    nonFreq: nonDist > 0 ? nonMotifs / nonDist : 0,
  });

  const sepFreq = sepDist > 0 ? sepMotifs / sepDist : 0;
  const nonFreq = nonDist > 0 ? nonMotifs / nonDist : 0;

  document.getElementById('iso3-progress').style.width = '100%';
  document.getElementById('iso3-status').textContent = 'Done.';

  const res = document.getElementById('iso3-results');
  res.style.display = '';
  res.innerHTML = `
    <div style="color:#c9a96e;font-weight:600;margin-bottom:8px">
      3-Motif: a=${a.toFixed(2)}, b=${b.toFixed(2)}, ε=${eps.toFixed(3)}
    </div>
    <table style="border-collapse:collapse;width:100%;font-family:monospace;font-size:.85rem">
      <tr style="color:#a0b8d0;border-bottom:1px solid #1e3060">
        <th style="text-align:left;padding:4px 8px"></th>
        <th style="text-align:right;padding:4px 8px">Length</th>
        <th style="text-align:right;padding:4px 8px">Notes</th>
        <th style="text-align:right;padding:4px 8px">Motif count</th>
        <th style="text-align:right;padding:4px 8px">Frequency (per unit length)</th>
      </tr>
      <tr style="color:#e8d5b7">
        <td style="padding:4px 8px">Separating</td>
        <td style="text-align:right;padding:4px 8px">${sepDist.toFixed(1)}</td>
        <td style="text-align:right;padding:4px 8px">${sepMusic.length.toLocaleString()}</td>
        <td style="text-align:right;padding:4px 8px">${sepMotifs.toLocaleString()}</td>
        <td style="text-align:right;padding:4px 8px">${sepFreq.toExponential(4)}</td>
      </tr>
      <tr style="color:#e8d5b7">
        <td style="padding:4px 8px">Nonseparating</td>
        <td style="text-align:right;padding:4px 8px">${nonDist.toFixed(1)}</td>
        <td style="text-align:right;padding:4px 8px">${nonMusic.length.toLocaleString()}</td>
        <td style="text-align:right;padding:4px 8px">${nonMotifs.toLocaleString()}</td>
        <td style="text-align:right;padding:4px 8px">${nonFreq.toExponential(4)}</td>
      </tr>
    </table>
  `;

  if (freqSamples.length > 1) {
    document.getElementById('iso3-plot-wrap').style.display = '';
    const cv = document.getElementById('iso3-freq-plot');
    const W = cv.width, H = cv.height;
    const ctx = cv.getContext('2d');
    ctx.clearRect(0, 0, W, H);
    ctx.fillStyle = '#0a0a1a';
    ctx.fillRect(0, 0, W, H);

    const PAD_L = 72, PAD_R = 12, PAD_T = 12, PAD_B = 32;
    const plotW = W - PAD_L - PAD_R;
    const plotH = H - PAD_T - PAD_B;

    const tMax = freqSamples[freqSamples.length - 1].t;
    const allFreqs = freqSamples.flatMap(s => [s.sepFreq, s.nonFreq]).filter(v => v > 0);
    const yMax = allFreqs.length > 0 ? Math.max(...allFreqs) * 1.15 : 1;
    const yMin = 0;

    function toX(t) { return PAD_L + (t / tMax) * plotW; }
    function toY(v) { return PAD_T + plotH - ((v - yMin) / (yMax - yMin)) * plotH; }

    ctx.strokeStyle = '#1e2e4a';
    ctx.lineWidth = 1;
    ctx.fillStyle = '#778899';
    ctx.font = '10px monospace';
    ctx.textAlign = 'right';
    const yTicks = 5;
    for (let i = 0; i <= yTicks; i++) {
      const v = yMax * i / yTicks;
      const y = toY(v);
      ctx.beginPath(); ctx.moveTo(PAD_L, y); ctx.lineTo(PAD_L + plotW, y); ctx.stroke();
      ctx.fillText(v.toExponential(2), PAD_L - 4, y + 3);
    }
    ctx.textAlign = 'center';
    const xStep = Math.pow(10, Math.floor(Math.log10(tMax / 5)));
    for (let t = 0; t <= tMax; t += xStep) {
      const x = toX(t);
      ctx.beginPath(); ctx.moveTo(x, PAD_T); ctx.lineTo(x, PAD_T + plotH); ctx.stroke();
      ctx.fillText(t >= 1000 ? (t/1000).toFixed(0)+'k' : t.toFixed(0), x, PAD_T + plotH + 14);
    }

    ctx.strokeStyle = '#4466aa';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(PAD_L, PAD_T); ctx.lineTo(PAD_L, PAD_T + plotH);
    ctx.lineTo(PAD_L + plotW, PAD_T + plotH);
    ctx.stroke();

    ctx.fillStyle = '#a0b8d0';
    ctx.font = '11px monospace';
    ctx.textAlign = 'center';
    ctx.fillText('hyperbolic length', PAD_L + plotW / 2, H - 4);
    ctx.save();
    ctx.translate(12, PAD_T + plotH / 2);
    ctx.rotate(-Math.PI / 2);
    ctx.fillText('frequency', 0, 0);
    ctx.restore();

    ctx.strokeStyle = '#ff7744';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    freqSamples.forEach((s, i) => {
      const x = toX(s.t), y = toY(s.sepFreq);
      i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
    });
    ctx.stroke();

    ctx.strokeStyle = '#44aaff';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    freqSamples.forEach((s, i) => {
      const x = toX(s.t), y = toY(s.nonFreq);
      i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
    });
    ctx.stroke();
  }

  document.getElementById('iso3-btn-run').disabled = false;
  document.getElementById('iso3-btn-stop').disabled = true;
}

async function playIsomelodic(which) {
  const music = which === 'sep' ? isoSepMusic : isoNonMusic;
  if (!music || music.length === 0) return;
  if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();

  isoAudioStop[which] = false;
  document.getElementById('iso-btn-play-' + which).disabled = true;
  document.getElementById('iso-btn-stop-' + which).disabled = false;

  const frequencies = [440.00, 554.37, 659.25];
  const speedMul = 1.0;
  const maxDur = 60;
  const notes = frequencies.map(f => createMarimbaNote(f, 1.5));
  const infoEl = document.getElementById('iso-' + which + '-audio-info');

  let elapsed = 0;
  for (let i = 0; i < music.length; i++) {
    if (isoAudioStop[which]) break;
    const dt = music[i][0] / speedMul;
    elapsed += dt;
    if (elapsed > maxDur) break;
    await new Promise(r => setTimeout(r, dt * 1000));
    if (isoAudioStop[which]) break;
    const src = audioCtx.createBufferSource();
    src.buffer = notes[music[i][1] - 1];
    src.connect(audioCtx.destination);
    src.start();
    infoEl.textContent = `Note ${i+1}/${music.length} — ${elapsed.toFixed(1)}s`;
  }

  infoEl.textContent = 'Playback finished.';
  document.getElementById('iso-btn-play-' + which).disabled = false;
  document.getElementById('iso-btn-stop-' + which).disabled = true;
}

function isoStopAudio(which) {
  isoAudioStop[which] = true;
}

// ===== INIT: runs after panels are injected into the DOM =====
loadPanels().then(() => {
  // Wire slider display updates
  for (const [id, cfg] of Object.entries(sliderConfigs)) {
    const el = document.getElementById(id);
    if (!el) continue;
    el.addEventListener('input', () => {
      document.getElementById(cfg.display).textContent = cfg.fmt(parseFloat(el.value));
    });
  }
  for (const [id, cfg] of Object.entries(isoSliderConfigs)) {
    const el = document.getElementById(id);
    if (!el) continue;
    el.addEventListener('input', () => {
      document.getElementById(cfg.display).textContent = cfg.fmt(parseFloat(el.value));
    });
  }

  // Auto-build surface and render markdown
  initMarkdown();
  buildSurface();

  // Draw iso hexagons on load (fixed params L1=5, L2=L3=3)
  (function() {
    const l = [5, 3, 3];
    const sepG = createGluingSeparatingS2();
    const nonG = createGluingNonseparatingS2();
    const sepP = buildPolytopes(sepG, l);
    const nonP = buildPolytopes(nonG, l);
    drawHexagons([0,1,2,3].map(i => document.getElementById('iso-sep-c' + i)), sepP, sepG);
    drawHexagons([0,1,2,3].map(i => document.getElementById('iso-non-c' + i)), nonP, nonG);
    drawHexagons([0,1,2,3].map(i => document.getElementById('iso2-sep-c' + i)), sepP, sepG);
    drawHexagons([0,1,2,3].map(i => document.getElementById('iso2-non-c' + i)), nonP, nonG);
  })();

  // Load iso-error.md for Part 2
  (async function() {
    const container = document.getElementById('iso-error-md-content');
    if (!container) return;
    try {
      const resp = await fetch('story/iso-error.md');
      if (resp.ok) { renderMd(container, await resp.text()); return; }
    } catch(e) {}
    container.innerHTML = '<p style="color:#888;font-style:italic">TODO</p>';
  })();

  setTimeout(trySetupSvgZoomPan, 500);
});
