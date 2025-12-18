classdef fundamental_domain
    %FUNDAMENTAL_DOMAIN This class represents the fundamental domain of the
    %surface. At the moment, this is given by a octagone; in particular, it
    %is given by a sequence of 8 points 

    properties
        Property1
    end

    methods
        function obj = fundamental_domain(inputArg1,inputArg2)
            %FUNDAMENTAL_DOMAIN Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end