classdef fundamental_domain
    %FUNDAMENTAL_DOMAIN This class represents the fundamental domain of the
    %surface. At the moment, this is given by a octagone; in particular, it
    %is given by a sequence of 8 points 

    properties
        points;
    end

    methods
        function obj = fundamental_domain(points_given)
            obj.points = points_given;
        end

    end
end