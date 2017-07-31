function RotateCamera

f = 4500;
width = 640;
height = 480;
px = width/2;
py = height/2;
K = [f 0 px; 0 f py; 0 0 1];
numOfImages = 10;
center_of_mass = [.5 .5 .5];
radius = 5;

theta = 0:0.02:2*pi;

h1 = figure(2);
clf;
i=1;
camera_offset = [radius*cos(theta(i)); radius*sin(theta(i)); 0];
camera_center = camera_offset + center_of_mass';


rz = [-cos(theta(i)); -sin(theta(i)); 0];
ry = [0 0 -1]';
rx = [-sin(theta(i)); cos(theta(i)); 0];
R = [rx'; ry'; rz'];
C = camera_center;
P = K * R * [ eye(3) -C];

dimsOfRotationMatrix = 3;
transformGenerator = TransformGenerator(dimsOfRotationMatrix, numOfImages, K);
transformGenerator.GenerateTransforms();

for n = 1:numOfImages
	figure(2);
	clf;
	% Plot camera trajectory
	plot3(radius*cos(theta)+center_of_mass(1), radius*sin(theta)+center_of_mass(2), zeros(size(theta))+center_of_mass(3), 'k:');
	R = transformGenerator.GetRotation(n);
	% Plot world coordinate
	DrawAxis(center_of_mass, R(1,:), R(2,:), R(3,:));
	pause(.5)
end

function DrawAxis(c, rx, ry, rz)

hold on
plot3([c(1) c(1)+rx(1)], [c(2) c(2)+rx(2)], [c(3) c(3)+rx(3)], 'r-', 'LineWidth', 2);
hold on
plot3([c(1) c(1)+ry(1)], [c(2) c(2)+ry(2)], [c(3) c(3)+ry(3)], 'g-', 'LineWidth', 2);
hold on
plot3([c(1) c(1)+rz(1)], [c(2) c(2)+rz(2)], [c(3) c(3)+rz(3)], 'b-', 'LineWidth', 2);
axis equal