classdef segment
    %SEGMENT A segment, given by its endpoints.

    properties
        startpoint;
        endpoint;
    end

    methods

        function obj = segment(inputArg1,inputArg2)
            %SEGMENT Construct an instance of this class
            %   Give startpoint and endpoint
            assert(all(size(inputArg1)==[2,1]));
            assert(all(size(inputArg2)==[2,1]), 'Make sure points are given as 2-1 arrays');

            obj.startpoint = inputArg1;
            obj.endpoint = inputArg2;
        end

        function [center, radius] = geodesic_circonference(obj, draw_plot)

            arguments
                obj segment
                draw_plot (1,1) int64 = 0
            end
            
            % Calculate the midpoint of the segment
            midpoint = (obj.startpoint + obj.endpoint) / 2;

            % Calculate the distance between the startpoint and endpoint
            segment_length = norm(obj.startpoint - obj.endpoint);

            % Let ned be such that midpoint + ned * unit_vector_perp is the 
            % center of the circonference
            
            % Compute the unit vector perpendicular to the line between startpoint and endpoint
            direction_vector = obj.endpoint - obj.startpoint; % Direction vector of the segment
            unit_vector = direction_vector / norm(direction_vector); % Unit vector in the direction of the segment
            unit_vector_perp = [-unit_vector(2); unit_vector(1)]; % Perpendicular unit vector


            % Find ned solving the equation of distances and
            % perpedicularity:
            % ned^2 + (segment_length / 2)^2 = norm(midpoint+unit_vector_perp*ned)^2 - 1;
            
            numerator = (segment_length^2)/4 - norm(midpoint)^2 + 1;
            ned = numerator / (2 * midpoint' * unit_vector_perp);


            % Calculate the center of the circonference
            center = midpoint+unit_vector_perp*ned; % Adjusting the center based on ned
            

            % The radius of the circonference
            radius = sqrt(norm(midpoint+unit_vector_perp*ned)^2 - 1);

            if draw_plot ~= 0
                % Create theta values for the circle
                theta = linspace(0, 2 * pi, 1000); % 100 points from 0 to 2*pi
                
                % Calculate x and y coordinates for the circumference
                x = center(1) + radius * cos(theta);
                y = center(2) + radius * sin(theta);
                
                % Plot the circle
                plot(x, y, 'b-'); % Plot the circumference in blue
                hold on;
                plot(obj.startpoint(1), obj.startpoint(2), '*'); % Plot the segment in red
                plot(obj.endpoint(1), obj.endpoint(2), '*g'); % Plot the segment in red
                axis equal;
                grid on;
                title('Circle with 90-degree intersection at unit circumference');
                xlabel('X-axis');
    
    
    
                % Draw the unit circumference
                unit_radius = 1; % Radius of the unit circle
                unit_center = [0;0]; % Center of the unit circle at the midpoint of the segment
                
                % Generate points on the circumference of the unit circle
                unit_x = unit_center(1) + unit_radius * cos(theta);
                unit_y = unit_center(2) + unit_radius * sin(theta);
                
                % Plot the unit circle
                plot(unit_x, unit_y, 'g--'); % Plot the unit circumference in green dashed line
                ylabel('Y-axis');
                hold off
            end

        end

        function v = tangent_center_startpoint(obj)
            [c, ~] = geodesic_circonference(obj);
            vec_help = (c - obj.startpoint) / norm(c - obj.startpoint); % Calculate the tangent vector

            if det([(c - obj.startpoint), (c - obj.endpoint)]) > 0
                v = [vec_help(2); -vec_help(1)];
            else
                v = [-vec_help(2); vec_help(1)];
            end
        end

        function v = tangent_center_endpoint(obj)
            [c, ~] = geodesic_circonference(obj);
            vec_help = (c - obj.endpoint) / norm(c - obj.endpoint); % Calculate the tangent vector

            if (c-obj.endpoint)' * obj.startpoint > 0
                v = [-vec_help(2); vec_help(1)];
            else
                v = [vec_help(2); -vec_help(1)];
            end
        end

        function ang = angle(seg1, seg2)
            % The angle to move the tangent vector in startpoint of seg1 to
            % the tangent vector in startpoint of seg2
            assert(all(seg1.startpoint == seg2.startpoint));
            v1 = tangent_center_startpoint(seg1);
            v2 = tangent_center_startpoint(seg2);
            ang = angleCW2D(v1, v2);
        end

        function inv_seg = invert(seg)
            inv_seg = segment(seg.endpoint, seg.startpoint);
        end

        function plot(obj, num_points)
            % plot  Plot segment(s) in 2-D.
            %   H = plot(seg)
            %   plot(ax, seg, ...)
            arguments
                obj 
                num_points = 1000
            end

            [center, radius] = geodesic_circonference(obj);
            ang1 = angleCW2D([1;0], obj.startpoint - center, "counterclockwise");
            ang2 = angleCW2D([1;0],  obj.endpoint - center, "counterclockwise");
            
            if abs(ang1-ang2)>pi
                if ang2>ang1
                    ang2=ang2-2*pi;
                else
                    ang1 = ang1-2*pi;
                end
            end

            theta = linspace(ang1, ang2, num_points);
            x = center(1) + radius * cos(theta);
            y = center(2) + radius * sin(theta);
            
            % Plot the arc
            plot(x, y, 'b-');
            hold on;
            plot(obj.startpoint(1), obj.startpoint(2), '*');
            plot(obj.endpoint(1), obj.endpoint(2), '*g');
            axis equal;
            grid on;
            title('Segment');
            xlabel('X-axis');

            % Draw the unit circumference
            unit_radius = 1; % Radius of the unit circle
            unit_center = [0;0]; % Center of the unit circle at the midpoint of the segment
            
            % Generate points on the circumference of the unit circle
            theta = linspace(0, 2*pi, 1000);
            unit_x = unit_center(1) + unit_radius * cos(theta);
            unit_y = unit_center(2) + unit_radius * sin(theta);
            
            % Plot the unit circle
            plot(unit_x, unit_y, 'g--'); % Plot the unit circumference in green dashed line
            ylabel('Y-axis');
            hold off


        end

    end
end