classdef PlaneStressElement3d3n < TriangularElement
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
    end
    
    methods
        %Constructor
        function planeStressElement3d3n = PlaneStressElement3d3n(id,nodeArray)
            
            requiredPropertyNames = cellstr(["YOUNGS_MODULUS", "POISSON_RATIO", ...
                                             "THICKNESS", "NUMBER_GAUSS_POINT", ...
                                             "DENSITY"]);
                                         
            %define the arguments for the super class constructor call
            if nargin == 0
                super_args = {};
            elseif nargin == 2
                if ~(length(nodeArray) == 3 && isa(nodeArray,'Node'))
                    error('problem with the nodes in element %d', id);
                end
                super_args = {id, nodeArray, requiredPropertyNames};
            end

            %call the super class constructor
            planeStressElement3d3n@TriangularElement(super_args{:});
            planeStressElement3d3n.dofNames = cellstr(["DISPLACEMENT_X", "DISPLACEMENT_Y"]);
        end
    
        %Initialization
        function initialize(planeStressElement3d3n)
            checkConvexity(planeStressElement3d3n);
        end

        function responseDoF = getResponseDofArray(planeStressElement, step)

            responseDoF = zeros(8,1);
            for itNodes = 1:1:4
                nodalDof = planeStressElement.nodeArray(itNodes).getDofArray;
                nodalDof = nodalDof.';

                for itDof = 2:(-1):1
                    responseDoF(3*itNodes-(itDof-1),1) = nodalDof(4-itDof).getValue(step);
                end
            end
        end

        function [N_mat, N, B, J] = computeShapeFunction(planeStressElement3d3n,tCoord)
            
            % Shape Function and Derivatives   
             N = tCoord;           

             N_Diff_Par = [1 0 -1
                            0 1 -1];

            
            N_mat = sparse(2,6);
            N_mat(1,1:2:end) = N(:);
            N_mat(2,2:2:end) = N(:);
            
            % Coordinates of the nodes forming one element 
            ele_coords = zeros(3,2); 
            for i=1:3
                ele_coords(i,1) = planeStressElement3d3n.nodeArray(i).getX;
                ele_coords(i,2) = planeStressElement3d3n.nodeArray(i).getY;
            end

            
            % Jacobian 
            J = N_Diff_Par * ele_coords;
            
            Ntest_Diff = J \ N_Diff_Par;
                    
 
            % Assembling the B Matrix
            B = sparse(3,6);
            B(1,1:2:end) = Ntest_Diff(1,:);
            B(3,2:2:end) = Ntest_Diff(1,:);
            B(2,2:2:end) = Ntest_Diff(2,:);
            B(3,1:2:end) = Ntest_Diff(2,:);

        end

        function stiffnessMatrix = computeLocalStiffnessMatrix(planeStressElement3d3n)
            EModul = planeStressElement3d3n.getPropertyValue('YOUNGS_MODULUS');
            prxy = planeStressElement3d3n.getPropertyValue('POISSON_RATIO');
            nr_gauss_points = planeStressElement3d3n.getPropertyValue('NUMBER_GAUSS_POINT');
            thickness = planeStressElement3d3n.getPropertyValue('THICKNESS');

            % Moment-Curvature Equations
            D = [1    prxy    0; prxy     1   0; 0    0   (1-prxy)/2];
            % Material Matrix D
            D = D * EModul * thickness / (1-prxy^2);
            
            stiffnessMatrix = sparse(6,6);            
            for i = 1 : nr_gauss_points

                [w,g] = returnGaussPointTrig(nr_gauss_points,i);
                [~, ~, B, J] = computeShapeFunction(planeStressElement3d3n,g);
                stiffnessMatrix = stiffnessMatrix + ...
                w * B' * D * B * 0.5 * det(J);
            end
        end
        
        function massMatrix = computeLocalMassMatrix(planeStressElement3d3n)
            %Formulation of the Massmatrix based on the Shape Functions
            
            density = planeStressElement3d3n.getPropertyValue('DENSITY');
            thickness = planeStressElement3d3n.getPropertyValue('THICKNESS');
            nr_gauss_points = planeStressElement3d3n.getPropertyValue('NUMBER_GAUSS_POINT');

            dens_mat = sparse(2,2);
            dens_mat(1,1) = density*thickness; 
            dens_mat(2,2) = dens_mat(1,1); 

            massMatrix = sparse(6,6);
            for i = 1 : nr_gauss_points
                
                [w,g] = returnGaussPointTrig(nr_gauss_points,i);
                [N_mat, ~, ~, J] = computeShapeFunction(planeStressElement3d3n,g);
  
                massMatrix = massMatrix + N_mat' * dens_mat * N_mat * 0.5 * det(J) * w;
            end
        end
        
        function dampingMatrix = computeLocalDampingMatrix(e)
            eProperties = e.getProperties;
            dampingMatrix = sparse(6,6);

            if (eProperties.hasValue('RAYLEIGH_ALPHA'))
                alpha = eProperties.getValue('RAYLEIGH_ALPHA');
                dampingMatrix = dampingMatrix + alpha * element.computeLocalMassMatrix;
            end

            if (eProperties.hasValue('RAYLEIGH_BETA'))
                beta = eProperties.getValue('RAYLEIGH_BETA');
                dampingMatrix = dampingMatrix + beta * element.computeLocalStiffnessMatrix;
            end
        end
            
        function pl = drawDeformed(planeStressElement3d3n, step, scaling)
    
            x = [planeStressElement3d3n.nodeArray(1).getX + scaling * planeStressElement3d3n.nodeArray(1).getDofValue('DISPLACEMENT_X', step), ... 
                 planeStressElement3d3n.nodeArray(2).getX + scaling * planeStressElement3d3n.nodeArray(2).getDofValue('DISPLACEMENT_X', step), ... 
                 planeStressElement3d3n.nodeArray(3).getX + scaling * planeStressElement3d3n.nodeArray(3).getDofValue('DISPLACEMENT_X', step), ...
                 planeStressElement3d3n.nodeArray(1).getX + scaling * planeStressElement3d3n.nodeArray(1).getDofValue('DISPLACEMENT_X', step)];
             
            y = [planeStressElement3d3n.nodeArray(1).getY + scaling * planeStressElement3d3n.nodeArray(1).getDofValue('DISPLACEMENT_Y', step), ... 
                 planeStressElement3d3n.nodeArray(2).getY + scaling * planeStressElement3d3n.nodeArray(2).getDofValue('DISPLACEMENT_Y', step), ... 
                 planeStressElement3d3n.nodeArray(3).getY + scaling * planeStressElement3d3n.nodeArray(3).getDofValue('DISPLACEMENT_Y', step), ...
                 planeStressElement3d3n.nodeArray(1).getY + scaling * planeStressElement3d3n.nodeArray(1).getDofValue('DISPLACEMENT_Y', step)];
            
            z = [planeStressElement3d3n.nodeArray(1).getZ, planeStressElement3d3n.nodeArray(2).getZ, ...
                 planeStressElement3d3n.nodeArray(3).getZ, planeStressElement3d3n.nodeArray(1).getZ];
             
            pl = line(x,y,z);
        end
        
        function dofs = getDofList(element)
            dofs([1 3 5]) = element.nodeArray.getDof('DISPLACEMENT_X'); 
           
            dofs([2 4 6]) = element.nodeArray.getDof('DISPLACEMENT_Y');
        end
        
        function vals = getValuesVector(element, step)
            vals = zeros(1,6);
            
            vals([1 3 5]) = element.nodeArray.getDofValue('DISPLACEMENT_X',step);

            vals([2 4 6]) = element.nodeArray.getDofValue('DISPLACEMENT_Y',step);
        end
        
        function [stressValue, element_connect] = computeElementStress(elementArray,nodeArray)

            element_connect = zeros(length(elementArray),3);
            stressValue = zeros(3,length(nodeArray));
            
            for i = 1:length(elementArray)

                element_connect(i,1:3) = elementArray(i).getNodes.getId();
                stressPoints = [1 0 0;0 1 0;0 0 1];
                EModul = elementArray(i).getPropertyValue('YOUNGS_MODULUS');
                prxy = elementArray(i).getPropertyValue('POISSON_RATIO');
                % Moment-Curvature Equations
                D = [1    prxy    0; prxy     1   0; 0    0   (1-prxy)/2];
                % Material Matrix D
                D = D * EModul / (1-prxy^2);
                
                for j = 1:3
                    [~, ~, B, ~] = computeShapeFunction(elementArray(i),stressPoints(j,:));
                    displacement_e = getValuesVector(elementArray(i),1);
                    displacement_e = displacement_e';
                    strain_e = B * displacement_e;
                    stress_e = D * strain_e;
                    
                    % elementwise stress calculation
                    sigma_xx(i,j) = stress_e(1);
                    sigma_yy(i,j) = stress_e(2);
                    sigma_xy(i,j) = stress_e(3);

                end
            end
            
            for k = 1 : length(nodeArray)
                [I,J] = find(element_connect == k);
                
                sum_sigma_xx = 0;
                sum_sigma_yy = 0;
                sum_sigma_xy = 0;
                
                for l = 1: length(I)
                    sum_sigma_xx = sum_sigma_xx + sigma_xx(I(l),J(l));
                    sum_sigma_yy = sum_sigma_yy + sigma_yy(I(l),J(l));
                    sum_sigma_xy = sum_sigma_xy + sigma_xy(I(l),J(l));
                end
                
                smooth_sigma_xx(k) = sum_sigma_xx/length(I);
                smooth_sigma_yy(k) = sum_sigma_yy/length(I);
                smooth_sigma_xy(k) = sum_sigma_xy/length(I);
                
                vec = zeros(2,2);
                lamda = zeros(2,2);

                stress_ele = [smooth_sigma_xx(k) smooth_sigma_xy(k);
                smooth_sigma_xy(k) smooth_sigma_yy(k)];
                [vec,lamda] = eig(stress_ele);

                prin_I(k) = lamda(1,1);
                prin_II(k) = lamda(2,2);
                prI_dir(k,:) = vec(:,1);
                prII_dir(k,:) = vec(:,2);

                vm_stress(k) = sqrt(prin_I(k).^2 + prin_II(k).^2 - prin_I(k) * prin_II(k));
            end
            
        stressValue(1,:) = smooth_sigma_xx;
        stressValue(2,:) = smooth_sigma_yy;
        stressValue(3,:) = smooth_sigma_xy;
        stressValue(4,:) = prin_I;
        stressValue(5,:) = prin_II;
        stressValue(6,:) = vm_stress;        
        end
    
    end
    
    methods (Static)
        function ord = drawOrder()
            
            ord = [1,2,3,1];
        end        
    end
end



