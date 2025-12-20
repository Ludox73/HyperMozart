classdef point_and_tg_vector
    %POINT_AND_TG_VECTOR Simply a point in the Poincare model and a vector
    %in its tangent in H^2

    properties
        point
        tg_vector
    end

    methods
        function obj = point_and_tg_vector(inputArg1,inputArg2)
            %POINT_AND_TG_VECTOR Simply a point in the Poincare model and a vector
            %in its tangent in H^2
            obj.point = inputArg1;
            obj.tg_vector = inputArg2;
        end

        function [center, radius] = geodesic_circonference_tg_vec(obj, draw_plot)
            % Finds the geodesic that passes thorugh the point with
            % velocity tg_vector
            arguments
                obj point_and_tg_vector
                draw_plot (1,1) int64 = 0
            end

            midpoint = obj.point;
            segment_length = 0;

            direction_vector = obj.tg_vector; % Direction vector of the segment
            unit_vector = direction_vector / norm(direction_vector); % Unit vector in the direction of the segment
            unit_vector_perp = [-unit_vector(2); unit_vector(1)]; % Perpendicular unit vector
            
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
        function plot(obj, varargin)
            % plot  Plot the point and the vector
                % Extract the point and vector for plotting
                pointh = obj.point;
                vectorh = obj.tg_vector;
    
                % Define the scale for the vector
                scale = 0.1; % Adjust this value for vector length in the plot
    
    
                % Plot the point
                plot(pointh(1), pointh(2), 'ro', 'MarkerSize', 10, 'DisplayName', 'Point'); % Red point
                hold on;
    
                % Plot the tangent vector
                quiver(pointh(1), pointh(2), vectorh(1) * scale, vectorh(2) * scale, ...
                    'b', 'LineWidth', 2, 'DisplayName', 'Tangent Vector'); % Blue arrow for the vector
                legend show;
            end
    end
end