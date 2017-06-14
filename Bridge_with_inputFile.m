io = ModelIO('tests/validation_bridge_input.msh');
            model = io.readModel;
            
            model.getModelPart('fixed_support').fixDof('DISPLACEMENT_X');
            model.getModelPart('fixed_support').fixDof('DISPLACEMENT_Y');
            model.getModelPart('roller_support').fixDof('DISPLACEMENT_Y');
            model.getAllNodes.fixDof('DISPLACEMENT_Z');
            
            addPointLoad(model.getNodes([3 5 9 11]),10,[0 -1 0]);
            addPointLoad(model.getNode(7),16,[0 -1 0]);
            
            SimpleSolvingStrategy.solve(model);
            
            actualDisplacementX = model.getAllNodes.getDofValue('DISPLACEMENT_X');
            actualDisplacementY = model.getAllNodes.getDofValue('DISPLACEMENT_Y');
            
            createOutputFile(model);
            
            