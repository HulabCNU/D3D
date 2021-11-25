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


rel_path = '/home/pc3d/AzureKinect_ws/Best_Kinect/colmap';
% txt_path = strcat (rel_path,'/images.txt');% 读入iamges.txt
ply1_path = strcat (rel_path,'/part1/sparse1.ply');% 读入ply
ply2_path = strcat (rel_path,'/part2/sparse2.ply');% 读入ply
txt1_path = strcat (rel_path,'/part1/images.txt');% 读入iamges.txt
txt2_path = strcat (rel_path,'/part2/images.txt');% 读入iamges.txt

trans_path = strcat (rel_path,'/trans/');
video_path = strcat (rel_path,'/recon/');
video_name = 'recon';


%% 读取images.txt中有关相机四元数和平移向量的信息，包含官方代码
images = containers.Map('KeyType', 'int64', 'ValueType', 'any');
fid = fopen(txt1_path);
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

%% 读取images.txt中有关相机四元数和平移向量的信息，包含官方代码
images = containers.Map('KeyType', 'int64', 'ValueType', 'any');
fid = fopen(txt2_path);
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
    data_R2{i} = image.R;
    data_t2{i} = image.t;
    data_T2{i}(1:3,1:3)=image.R;
    data_T2{i}(4,1:3)=image.t;
    data_T2{i}(1:4,4)=[0;0;0;1];
    data_name1{i} = image.name;
    %     num_cam1 = i;
    %     i = i+1;
    
end
fclose(fid);
% num = images.Count; %多少张图

% num = 1;


%% show one frame
ptCloudA = pcread(ply1_path);
ptCloudB = pcread(ply2_path);
% pcshow(ptCloudA);
% hold on;
% pcshow(ptCloudB);
% figure
% axis([-20 20 -15 15 0 40]);
%pcshowpair(ptCloudA,ptCloudB);
% ptCloudOut = pcmerge(ptCloudA, ptCloudB, 1);
% pcshow(ptCloudOut);
% % ptCloud = pcread(ply1_path);
% ptCloud = pcread(ply2_path);
% figure
% axis([-20 20 -15 15 15 50]);
% view([0, -70])
xlabel('X')
ylabel('Y')
zlabel('Z')


%ptCloudOut_A = pctransform(ptCloudA, invert(tf1));
%ptCloudOut_B = pctransform(ptCloudB, invert(tf2));
%ptCloudOut_B = pctransform(ptCloudOut_B, invtform2);

%pcshowpair(ptCloudOut_A,ptCloudOut_C);
%hold on
%pcshowpair(ptCloudOut_A,ptCloudOut_B);

num = 100;

%% 旋转加平移
for j = 1:1:num
    
    rot1 = data_T1{j}(1:3,1:3);
    trans1 = data_T1{j}(4,1:3);
    
    rot2 = data_T2{j}(1:3,1:3);
    trans2 = data_T2{j}(4,1:3);

    locA = rot1 * ptCloudA.Location' + trans1';
    ptA = pointCloud(locA');

    locB = rot2 * ptCloudB.Location' + trans2';
    ptB = pointCloud(locB');
    
    %     figure
    %hold on;
    %pcshow(ptCloudOut_B);
    %pcshow(ptB);
    pcshowpair(ptB,ptA);
    %pcshowpair(ptCloudOut_B,ptCloudOut_A);
    %     axis([-20 20 -15 15 -20 20]);
    view([0, -70])
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    pause(0.1)
    %im = frame2im(getframe(gcf));
    %save_path = [trans_path,data_name{j}];
    %imwrite(im,save_path);
    
end

% imgDir = dir([trans_path '*.jpg']);
% recon = VideoWriter(strcat(video_path,video_name),'Uncompressed AVI');
% recon.FrameRate = 20;
% open(recon);
% img = imread([trans_path imgDir(1).name]);%get the first pic
% si = size(img);
% n = si(1);
% m = si(2);
% for k = 1:1:num
%     img = imread([trans_path imgDir(k).name]);
%     img =  imresize(img,[n m]);
%     writeVideo(recon,img);
% end
% close(recon)
