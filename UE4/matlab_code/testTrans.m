clear
close all;
%% 各种地址 复制为info.txt
% rel_path = '/home/pc3d/AzureKinect_ws/Best_Kinect/colmap';
% % txt_path = strcat (rel_path,'/images.txt');% 读入iamges.txt
% ply1_path = strcat (rel_path,'/p1/sparse1.ply');% 读入ply
% ply2_path = strcat (rel_path,'/p2/sparse2.ply');% 读入ply
%
% ptCloudA = pcread(ply1_path);
% ptCloudB = pcread(ply2_path);
% figure
% axis([-20 20 -15 15 0 40]);
% pcshowpair(ptCloudA,ptCloudB);


rel_path = './';
% txt_path = strcat (rel_path,'/images.txt');% 读入iamges.txt
ply_path = strcat (rel_path,'../data/tank_v1/fused.ply');% 读入ply
txt_path = strcat (rel_path,'../data/tank_v1/images.txt');% 读入iamges.txt

%% 读取images.txt中有关相机四元数和平移向量的信息，包含官方代码
images = containers.Map('KeyType', 'int64', 'ValueType', 'any');
fid = fopen(txt_path);
tline = fgets(fid);  %读取指定文件中的下一行内容，并包含换行符。

while ischar(tline) % 当文件的该行是char类型时；
    elems = strsplit(tline);
    if numel(elems) < 4 || strcmp(elems(1), '#') % 字符少于4个，或者有#号（也就是前4排的说明）
        tline = fgets(fid);                      % 就换到下一行去
        continue
    end
    
    if mod(images.Count, 10) == 0   % 读txt的时候顺便数一数读了多少张图片，每10张计数一下
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
    data_R1{i} = image.R;
    data_t1{i} = image.t;
    data_T1{i}(1:3,1:3)=image.R;
    data_T1{i}(4,1:3)=image.t;
    data_T1{i}(1:4,4)=[0;0;0;1];
    data_name{i} = image.name;
    %     num_cam1 = i;
    %     i = i+1;
    
end
fclose(fid);
num = images.Count; %多少张图

ptCloud = pcread(ply_path);
for j = 1:1:num
    
    rot1 = data_T1{j}(1:3,1:3);
    trans1 = data_T1{j}(4,1:3);

    loc = rot1 * ptCloud.Location' + trans1';
    pt = pointCloud(loc');
    
    barycenter = mean(pt.Location);

    %     figure
    %hold on;
    %pcshow(ptCloudOut_B);
    %pcshow(ptB);
    pcshow(pt);
    %pcshowpair(ptCloudOut_B,ptCloudOut_A);
    axis([-10 10 -10 10 0 20]);
    view([0, -70])
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    pause(0.1)
    %im = frame2im(getframe(gcf));
    %save_path = [trans_path,data_name{j}];
    %imwrite(im,save_path);
    
end