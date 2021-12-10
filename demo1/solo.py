import os
import argparse
import numpy as np
import matplotlib.pyplot as plt
import read_write_model
from pyntcloud import PyntCloud
import plyfile

from read_write_model import read_model, write_model, qvec2rotmat, rotmat2qvec

class Model:
    def __init__(self):
        self.cameras = []
        self.images = []
        self.points3D = []

    def read_model(self, path, ext=""):
        self.cameras, self.images, self.points3D = read_model(path, ext)

    def add_points(self, min_track_len=3, remove_statistical_outlier=True):
        pcd = open3d.geometry.PointCloud()

        xyz = []
        rgb = []
        for point3D in self.points3D.values():
            track_len = len(point3D.point2D_idxs)
            if track_len < min_track_len:
                continue
            xyz.append(point3D.xyz)
            rgb.append(point3D.rgb / 255)

        pcd.points = open3d.utility.Vector3dVector(xyz)
        pcd.colors = open3d.utility.Vector3dVector(rgb)

        # remove obvious outliers
        if remove_statistical_outlier:
            [pcd, _] = pcd.remove_statistical_outlier(nb_neighbors=20,
                                                      std_ratio=2.0)

        # open3d.visualization.draw_geometries([pcd])
        self.__vis.add_geometry(pcd)
        self.__vis.poll_events()
        self.__vis.update_renderer()

    def create_window(self):
        self.__vis = open3d.visualization.Visualizer()
        self.__vis.create_window()

    def show(self):
        self.__vis.poll_events()
        self.__vis.update_renderer()
        self.__vis.run()
        self.__vis.destroy_window()

# def pctransform(pcd, rot, t):
#     pcd_new = open3d.geometry.PointCloud()
#     xyz = []
#     for point3D in pcd.points:
#         xyz.append(point3D.xyz)
        
#     pcd_new.points = open3d.utility.Vector3dVector(xyz)
#     return pcd_new


def parse_args():
    parser = argparse.ArgumentParser(description="Visualize COLMAP binary and text models")
    parser.add_argument("--input_model", required=True, help="path to input model folder")
    parser.add_argument("--input_format", choices=[".bin", ".txt"],
                        help="input model format", default="")
    args = parser.parse_args()
    return args


def main():

    cameras1, images1, points1 = read_model("data")

    path_model1 = "data/fused.ply"

    assert os.path.isfile(path_model1)

    point_cloud = PyntCloud.from_file(path_model1)
    xyz_arr = point_cloud.points.loc[:, ["x", "y", "z"]].to_numpy()
    color_arr = point_cloud.points.loc[:, ["red", "green", "blue"]].to_numpy()
    p1 = xyz_arr
    c1 = color_arr


    for id1 in list(images1)[0:3]:
        trans = (0, -0.1, -0.7)

        print(id1)
        image1 = images1[id1]
        rot1 = qvec2rotmat(image1.qvec)
        tran1 = image1.tvec


        p1_new = np.matmul(p1, rot1.transpose()) + tran1


        fig = plt.figure(figsize = (10, 7))

        ax = plt.axes(projection = "3d")
        ax.view_init(elev=160,azim=90)
        ax.scatter3D(p1_new[:, 0], p1_new[:, 1], p1_new[:, 2], s=0.5, c=c1/255)



        # w = ax.can_zoom()
        ax.set_xlabel('X')
        ax.set_ylabel('Y')
        ax.set_zlabel('Z')
        # plt.axis([-4, 3, -1, 2, 2, 8])
        ax.set_xlim3d(-4,4)
        ax.set_ylim3d(-1,2)
        ax.set_zlim3d(3,6)

        plt.subplots_adjust(left=0, bottom=0, right=1, top=1)
        # plt.axis([x_min, x_max, y_min, y_max,z_min, z_max])
        name =  str(id1) + ".png"
        plt.savefig(name)
        plt.show()



if __name__ == "__main__":
    main()
