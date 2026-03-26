"use strict";

// ===== Distribution scatter plot (canvas-based for performance) =====
function drawDistribution(){
  if(!pointsDistribution||pointsDistribution.length===0)return;
  const maxPts=parseInt(document.getElementById('dist-max-pts').value)||100000;
  const D=pointsDistribution.length>maxPts?pointsDistribution.slice(0,maxPts):pointsDistribution;
  const canvas=document.getElementById('dist-canvas');
  const ctx=canvas.getContext('2d');
  const W=canvas.width,H=canvas.height;
  const pad={l:70,r:80,t:40,b:50};
  const pw=W-pad.l-pad.r,ph=H-pad.t-pad.b;

  const xMax=Math.max(...D.map(d=>d[0]));
  const yMin=-Math.PI,yMax=Math.PI;
  const tx=v=>pad.l+v/xMax*pw;
  const ty=v=>pad.t+(1-(v-yMin)/(yMax-yMin))*ph;

  // Log color scale
  const times=D.map(d=>d[2]).filter(t=>t>0);
  const logMin=Math.log10(Math.min(...times));
  const logMax=Math.log10(Math.max(...times));

  function rgbFromLog(t){
    if(t<=0)return[34,34,34];
    const frac=Math.max(0,Math.min(1,(Math.log10(t)-logMin)/(logMax-logMin||1)));
    return[
      Math.round(255*Math.min(1,Math.max(0,1.5*frac-0.5))),
      Math.round(255*Math.min(1,Math.max(0,frac<0.5?2*frac:1))),
      Math.round(255*Math.max(0,1-1.5*frac))
    ];
  }

  // Background
  ctx.fillStyle='#0a0a1a';ctx.fillRect(0,0,W,H);

  // Grid lines
  ctx.strokeStyle='#1a2a4a';ctx.lineWidth=1;
  const xStep=Math.pow(10,Math.floor(Math.log10(xMax)))/2;
  for(let gx=xStep;gx<=xMax;gx+=xStep){
    ctx.beginPath();ctx.moveTo(tx(gx),pad.t);ctx.lineTo(tx(gx),pad.t+ph);ctx.stroke();
  }
  for(let gy=-3;gy<=3;gy++){
    if(gy<yMin||gy>yMax)continue;
    ctx.beginPath();ctx.moveTo(pad.l,ty(gy));ctx.lineTo(pad.l+pw,ty(gy));ctx.stroke();
  }

  // Scatter points via ImageData for maximum speed
  const imgData=ctx.getImageData(0,0,W,H);
  const px=imgData.data;
  for(let i=0;i<D.length;i++){
    const d=D[i];
    const sx=Math.round(tx(d[0]));
    const sy=Math.round(ty(d[1]));
    if(sx<pad.l||sx>=pad.l+pw||sy<pad.t||sy>=pad.t+ph)continue;
    const rgb=rgbFromLog(d[2]);
    // Draw a 2x2 pixel dot
    for(let dy=-1;dy<=1;dy++){
      for(let dx=-1;dx<=1;dx++){
        const px2=sx+dx,py2=sy+dy;
        if(px2>=0&&px2<W&&py2>=0&&py2<H){
          const off=(py2*W+px2)*4;
          px[off]=rgb[0];px[off+1]=rgb[1];px[off+2]=rgb[2];px[off+3]=255;
        }
      }
    }
  }
  ctx.putImageData(imgData,0,0);

  // Axis labels (drawn after scatter so they're on top)
  ctx.fillStyle='#888';ctx.font='16px sans-serif';ctx.textAlign='center';
  for(let gx=0;gx<=xMax;gx+=xStep){
    ctx.fillText(gx.toFixed(1),tx(gx),pad.t+ph+22);
  }
  ctx.textAlign='right';
  for(let gy=-3;gy<=3;gy++){
    if(gy<yMin||gy>yMax)continue;
    ctx.fillText(gy.toFixed(1),pad.l-6,ty(gy)+5);
  }

  // Colorbar
  const cbX=W-pad.r+16,cbW=18,cbH=ph;
  for(let i=0;i<cbH;i++){
    const frac=1-i/cbH;
    const t=Math.pow(10,logMin+(logMax-logMin)*frac);
    const rgb=rgbFromLog(t);
    ctx.fillStyle=`rgb(${rgb[0]},${rgb[1]},${rgb[2]})`;
    ctx.fillRect(cbX,pad.t+i,cbW,1);
  }
  ctx.strokeStyle='#555';ctx.lineWidth=1;ctx.strokeRect(cbX,pad.t,cbW,cbH);
  ctx.fillStyle='#888';ctx.font='14px sans-serif';ctx.textAlign='left';
  const nLabels=5;
  for(let i=0;i<=nLabels;i++){
    const frac=1-i/nLabels;
    const val=Math.pow(10,logMin+(logMax-logMin)*frac);
    ctx.fillText(val.toFixed(1),cbX+cbW+4,pad.t+i/nLabels*cbH+5);
  }

  // Title and axis labels
  ctx.fillStyle='#c9a96e';ctx.font='18px sans-serif';ctx.textAlign='left';
  ctx.fillText(`Intersection Distribution (${D.length} points)`,pad.l,pad.t-14);
  ctx.fillStyle='#888';ctx.font='16px sans-serif';ctx.textAlign='center';
  ctx.fillText('Position on curve 1',pad.l+pw/2,H-8);
  ctx.save();ctx.translate(16,pad.t+ph/2);ctx.rotate(-Math.PI/2);ctx.fillText('Angle',0,0);ctx.restore();

  document.getElementById('dist-panel').style.display='';
  const capped=pointsDistribution.length>D.length?` (${pointsDistribution.length} total, showing first ${D.length})`:'';
  document.getElementById('dist-status').textContent=`${D.length} points plotted${capped}. Color = travel time (log scale).`;
}
