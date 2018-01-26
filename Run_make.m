%%
clear; clc;
%% Set Inputs
R_label_file='J:\projects\FAIR_users\moosa\Gordon/R.Gordon.32k_fs_LR.label.gii';
L_label_file='J:\projects\FAIR_users\moosa\Gordon/L.Gordon.32k_fs_LR.label.gii';
R_surf_file='J:\projects\FAIR_users\moosa\Gordon\MNI152.R.midthickness.32k_fs_LR.surf.gii';
L_surf_file='J:\projects\FAIR_users\moosa\Gordon\MNI152.L.midthickness.32k_fs_LR.surf.gii';
output_folder='J:\projects\FAIR_users\moosa\test';
path_wb_c = 'C:\Users\ahmemo\workbench\bin_windows64\wb_command';
gifti_path = 'W:/code/external/utilities/gifti-1.4';
make_euclidean_distance_matrix(R_label_file,L_label_file,R_surf_file,L_surf_file,output_folder,path_wb_c,gifti_path)