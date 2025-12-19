classdef hyp_isometry_2d
    %HYP_ISOMETRY_2D Summary of this class goes here
    %   Detailed explanation goes here

    properties
        poincare_model
        upper_half_model
    end

    methods
        function obj = hyp_isometry_2d(inputArg1,inputArg2)
            %HYP_ISOMETRY_2D Construct an instance of this class
            %   Detailed explanation goes here
            obj.poincare_model = inputArg1;
            obj.upper_half_model = inputArg2;
        end



        function new_point = apply_upper_half(obj,point)
            flag_type='complex';
            if all(size(point) == [2,1])
                point = point(1)+point(2)*1i;
                flag_type='vector';
            end

            if isnumeric(point) && ~isreal(point)
                M = obj.upper_half_model;
                new_point = (M(1,1)*point+M(1,2))/(M(2,1)*point+M(2,2));
                if strcmp( flag_type,'vector')
                    new_point = [real(new_point); imag(new_point)];
                end
            else
                error('Input point must be a real number or a complex number.');
            end
        end

        function new_point = apply_poincare(obj,point)
            flag_type='complex';
            if all(size(point) == [2,1])
                point = point(1)+point(2)*1i;
                flag_type='vector';
            end

            if isnumeric(point)
                M = obj.poincare_model;
                new_point = (M(1,1)*point+M(1,2))/(M(2,1)*point+M(2,2));
                if strcmp( flag_type,'vector' )
                    new_point = [real(new_point); imag(new_point)];
                end
            else
                error('Input point must be a real number or a complex number.');
            end
        end
    end
end