%% 读取images.txt中有关相机四元数和平移向量的信息，包含colmap官方代码
path_images = '../data/tank_v1/images.txt';
images = containers.Map('KeyType', 'int64', 'ValueType', 'any');
fid = fopen(path_images);
fid_out = fopen('../out/transform_data.txt', 'w');
% txt_path = strcat (rel_path,'/images.txt');% 读入iamges.txt
ply_path = '../data/tank_v1/fused.ply';

tline = fgets(fid);
while ischar(tline)
    elems = strsplit(tline);
    if numel(elems) < 4 || strcmp(elems(1), '#')
        tline = fgets(fid);
        continue
    end
    
    if mod(images.Count, 10) == 0
        fprintf('Reading image %d\n', images.length);
    end
    
    image = struct;
    image.image_id = str2num(elems{1});
    i = image.image_id;
    qw = str2double(elems{2});
    qx = str2double(elems{3});
    qy = str2double(elems{4});
    qz = str2double(elems{5});
    image.R = quat2rotm([qw, qx, qy, qz]);
    tx = str2double(elems{6});
    ty = str2double(elems{7});
    tz = str2double(elems{8});
    image.t = [tx; ty; tz];
    image.camera_id = str2num(elems{9});
    image.name = elems{10};
    tline = fgets(fid);
    elems = sscanf(tline, '%f');
    elems = reshape(elems, [3, numel(elems) / 3]);
    image.xys = elems(1:2,:)';
    image.point3D_ids = elems(3,:)';
    images(image.image_id) = image;
    tline = fgets(fid);
    %% 存储每一张图像对应的相机旋转矩阵和平移向量，并构造齐次变换矩阵
    data_R{i} = image.R;
    data_t{i} = image.t;
    data_T{i}(1:3,1:3)=image.R;
    data_T{i}(4,1:3)=image.t;
    data_T{i}(1:4,4)=[0;0;0;1];
    image.name
    
    %fprintf(fid_out, "%f, %f, %f, %f, %f, %f, %f \n", qw, qx, qy, qz, tx, ty, tz);
end
fclose(fid);

num = images.Count; %多少张图

ptCloud = pcread(ply_path);
for j = 1:1:num
    
    rot1 = data_T{j}(1:3,1:3);
    trans1 = data_T{j}(4,1:3);

    loc = rot1 * ptCloud.Location' + trans1';
    pt = pointCloud(loc');
    
    barycenter = mean(pt.Location);

%     pcshow(pt);
%     axis([-10 10 -10 10 0 20]);
%     view([0, -70])
%     xlabel('X')
%     ylabel('Y')
%     zlabel('Z')
%     pause(0.1)
    
    %rvec = rotationMatrixToVector(rot1);
    %rvec = rvec * 180/pi;    
    %fprintf(fid_out, "%f, %f, %f, %f, %f, %f \n", rvec(1), rvec(2), rvec(3), barycenter(1), barycenter(2), barycenter(3));
    quat1 = rotm2quat(rot1);
    fprintf(fid_out, "%f, %f, %f, %f, %f, %f, %f \n", quat1(1), quat1(2), quat1(3), quat1(4), barycenter(1), barycenter(2), barycenter(3));
end


fclose(fid_out);

