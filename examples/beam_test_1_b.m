%%%Test Beam

clear;

node01 = Node(1,0,0);
node02 = Node(2,2,0);
node03 = Node(3,4,0);
node04 = Node(4,4,1);
node05 = Node(5,2,1);
node06 = Node(6,0,1);

nodeArray = [node01 node02 node03 node04 node05 node06];

nodeArray.addDof({'DISPLACEMENT_X', 'DISPLACEMENT_Y'});

ele01 = QuadrilateralElement2d4n(1,[node01 node02 node05 node06]);
ele02 = QuadrilateralElement2d4n(2,[node02 node03 node04 node05]);

elementArray = [ele01,ele02];


node01.fixDof('DISPLACEMENT_X');
node01.fixDof('DISPLACEMENT_Y');
node04.fixDof('DISPLACEMENT_X');
node04.fixDof('DISPLACEMENT_Y');

addPointLoad(node03,1,[0 -1]);

model = FemModel(nodeArray, elementArray);

assembling = SimpleAssembler(model);
stiffnessMatrix = assembling.assembleGlobalStiffnessMatrix(model);
            
massMatrix = assembling.assembleGlobalMassMatrix(model);

solver = SimpleSolvingStrategy(model);
x = solver.solve();

step = 1;

VerschiebungDofs = model.getDofArray.getValue(step);

nodalForces = solver.getNodalForces(step);

v = Visualization(model);
v.setScaling(1);
v.plotUndeformed
v.plotDeformed
    
    