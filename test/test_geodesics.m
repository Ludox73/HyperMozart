classdef test_geodesics < matlab.unittest.TestCase
    methods(Test)
        function testCenterMatchesStartpoint(test)
            % Arrange
            seg = segment([0.1; 0], [0; 0.2]);
            tol = 1e-12;
            % Act
            [center, radius] = geodesic_circonference(seg);

            % Assert
            test.verifyLessThanOrEqual(abs(norm(center - seg.startpoint)-radius), tol, ...
                sprintf('Center differs from startpoint by more than %g', tol));
        end

        function testAngleComputation(test)

            seg1 = segment([0.1;0], [0; 0.1]);
            seg2 = segment([0.1;0], [0; 0.2]);
            tol = 1e-12;
            
            geodesic_circonference(seg1, 1);
            hold on
            geodesic_circonference(seg2, 1);
        
            ang = angle(seg1, seg2);
            
            % Assert
            expected_angle = 0.311752887110157;
            test.verifyLessThanOrEqual(abs(ang - expected_angle), tol, ...
                sprintf('Computed angle differs from expected value by more than %g', tol));
        end
    end
end