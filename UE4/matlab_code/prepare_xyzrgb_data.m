path_model = '../data/tank_v1/tank_recentered.ply';
path_out = '../out/xyzrgb_data.txt';
pc = pcread(path_model);
data = zeros(pc.Count, 6);
data(:, 1:3) = pc.Location;
data(:, 4:6) = pc.Color;
writematrix(data, path_out);