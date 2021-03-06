classdef DummyElement < Element
    %DUMMYELEMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        massMatrix
        dampingMatrix
        stiffnessMatrix
        dofArray
        restrictedDofs = Dof.empty
        nodeConnectivity
    end
    
    methods
        
        function obj = DummyElement(id, nodeArray)
            
            % define the arguments for the super class constructor call
            if nargin == 0
                super_args = {};
            elseif nargin == 2
                if ~ isa(nodeArray,'Node')
                    error('problem with the nodes in element %d', id);
                end
                super_args = {id, nodeArray, []};
            else
                msg = 'DummyElement: Wrong number of input arguments';
                err = MException('MATLAB:bm_mfem:invalidArguments',msg);
                throw(err);
            end
            
            % call the super class constructor
            obj@Element(super_args{:});
            obj.dofNames = [];
                        
        end
        
        function barycenter(obj)
        end
        
        function stiffnessMatrix = computeLocalStiffnessMatrix(obj)
            stiffnessMatrix = obj.stiffnessMatrix;
        end
        
        function massMatrix = computeLocalMassMatrix(obj)
            massMatrix = obj.massMatrix;
        end
        
        function dampingMatrix = computeLocalDampingMatrix(obj)
            dampingMatrix = obj.massMatrix;
        end
        
        function check(obj)
           %CHECK override the element check function. nothing has to be
           %    checked for the dummy element.
        end
        
        function dofs = getDofList(obj)
            dofs = obj.dofArray;
        end
        
        function vals = getValuesVector(obj, step)
            vals = obj.dofArray.getValue(step);
        end
        
        function vals = getFirstDerivativesVector(obj, step)
            vals = obj.dofArray.getFirstDerivativeValue(step);
        end
        
        function vals = getSecondDerivativesVector(obj, step)
            vals = obj.dofArray.getSecondDerivativeValue(step);
        end
        
        function update(obj)            
        end
        
        function initialize(obj)
        end
        
        function setMatrices(obj, massMatrix, dampingMatrix, stiffnessMatrix)
        %SETMATRICES sets the matrices M, C, and K for the element.
            obj.massMatrix = massMatrix;
            obj.dampingMatrix = dampingMatrix;
            obj.stiffnessMatrix = stiffnessMatrix;
        end
        
        function setDofOrder(obj, order)
        %SETDOFORDER rearranges the dof array (ordered nodewise by default)
        %   to match the ordering in the imported ANSYS matrices.
            obj.dofArray = arrayfun(@(n) n.getDofArray(), obj.nodeArray(order), 'Uniform', 0);
            obj.dofArray = [obj.dofArray{:}];
        end
        
        function setDofRestrictions(obj, restrictions)
        %SETDOFRESTRICTIONS removes dofs from the elemental dof array or 
        %   sets the value ~= 0 according to the ANSYS input. The dofs 
        %   restricted to 0 are then fixed.
            for ii = 1:length(restrictions{1})
                n = obj.nodeArray(obj.nodeArray.getId == restrictions{1}(ii));
                if restrictions{3}(ii) == 0
                    obj.dofArray(obj.dofArray.getId==n.getDof(restrictions{2}{ii}).getId) = [];
                    n.fixDof(restrictions{2}{ii});
                else
                    n.setDofValue(restrictions{2}{ii}, restrictions{3}(ii));
                end
            end
        end
        
        function setNodeConnectivity(obj, nc)
            obj.nodeConnectivity = nc;
        end
    end
    
end

