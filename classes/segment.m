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
            % perpedicularity
            numerator = (segment_length^2)/4 - norm(midpoint)^2 + 1;
            ned = numerator / (2 * midpoint' * unit_vector_perp);


            % Calculate the center of the circonference
            center = midpoint+unit_vector_perp*ned; % Adjusting the center based on ned
            

            % The radius of the circonference
            radius = sqrt(norm(midpoint+unit_vector_perp*ned)^2 - 1);

            if draw_plot ~= 0
                % Create theta values for the circle
                theta = linspace(0, 2 * pi, 100); % 100 points from 0 to 2*pi
                
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

            if (c-obj.startpoint)' * obj.endpoint > 0
                v = [-vec_help(2); vec_help(1)];
            else
                v = [vec_help(2); -vec_help(1)];
            end
        end

        function ang = angle(seg1, seg2)
            assert(seg1.startpoint == seg2.startpoint);
            tangent_center_startpoint
            
            
        end
    end
end