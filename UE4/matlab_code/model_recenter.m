ply_path = '../data/tank_v1/fused.ply';
ptCloud = pcread(ply_path);

rotvector = [-9 6.37 -3.56]*pi/180;
rot = rotationVectorToMatrix(rotvector);
trans = [0.38 -1.67 -3.48];

rot = rot';
%trans = -rot'*trans';

%loc = rot * ptCloud.Location' + trans';
loc = rot * ptCloud.Location' + trans';
pt = pointCloud(loc');
pt.Color = ptCloud.Color;


pcshow(pt)
pcwrite(pt, "../data/tank_v1/tank_recentered.ply");