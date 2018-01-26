function make_euclidean_distance_matrix(R_label_file,L_label_file,R_surf_file,L_surf_file,output_folder,path_wb_c,gifti_path)
%% Naming Outputs
f = filesep;

R_shape_file=[output_folder f 'R_surface_coordinates.shape.gii'];
L_shape_file=[output_folder f 'L_surface_coordinates.shape.gii'];
roi_folder=[output_folder f 'roi_files'];
mkdir(roi_folder);

coordinate_out=[output_folder f 'coordinates.csv'];
all_names_out=[output_folder f 'roi_names.txt'];
%% Creating shape file that contains all surface corrdinates on each gray ordinate
command = [path_wb_c ' -surface-coordinates-to-metric ' R_surf_file ' ' R_shape_file];
status = system(command);
command = [path_wb_c ' -surface-coordinates-to-metric ' L_surf_file ' ' L_shape_file];
status = system(command);
% Created with: wb_command -surface-coordinates-to-metric /mnt/max/shared/data/study/ABCD/ABCD_SIEMENS_SEFMNoT2/ohsu-sub-NDARINV3F6NJ6WW/ses-baselineYear1Arm1/HCP_release_20161027_v1.1/ohsu-sub-NDARINV3F6NJ6WW/MNINonLinear/ohsu-sub-NDARINV3F6NJ6WW.R.pial.164k_fs_LR.surf.gii pial_surf_coord_to_metric_out.shape.gii
surface_coordinates_R = gifti(R_shape_file);
surface_coordinates_L = gifti(L_shape_file);
%% Generate roi files for Gordon parcellation and take the mean of all the coordinates within the ROI for both hemispheres
R_parc_32k_fsLR_labels=gifti(R_label_file);
L_parc_32k_fsLR_labels=gifti(L_label_file);

num_L_rois=length(L_parc_32k_fsLR_labels.labels.name);
num_R_rois=length(R_parc_32k_fsLR_labels.labels.name);

all_roi_coordinates=[];
all_roi_names=[];

for i=2:num_L_rois
    roi_name=L_parc_32k_fsLR_labels.labels.name(i);
    gifti_label_to_roi = strjoin([path_wb_c ' -gifti-label-to-roi ' L_label_file ' ' roi_folder f roi_name '.func.gii -name ' roi_name],'');
    status = system(gifti_label_to_roi);
    roi=gifti(strjoin([roi_folder f roi_name '.func.gii'],''));
    mean_roi_coordinates=mean(surface_coordinates_L.cdata(roi.cdata==1,:));
    all_roi_coordinates=[all_roi_coordinates; mean_roi_coordinates];
    all_roi_names=[all_roi_names; roi_name];
    disp(roi_name) 
    disp(mean_roi_coordinates)
end
for i=2:num_R_rois
    roi_name=R_parc_32k_fsLR_labels.labels.name(i);
    gifti_label_to_roi = strjoin([path_wb_c ' -gifti-label-to-roi ' R_label_file ' ' roi_folder f roi_name '.func.gii -name ' roi_name],'');
    status = system(gifti_label_to_roi);
    roi=gifti(strjoin([roi_folder f roi_name '.func.gii'],''));
    mean_roi_coordinates=mean(surface_coordinates_R.cdata(roi.cdata==1,:));
    all_roi_coordinates=[all_roi_coordinates; mean_roi_coordinates];
    all_roi_names=[all_roi_names; roi_name];
    disp(roi_name)
    disp(mean_roi_coordinates)
end
%all_roi_coordinates = num2cell(all_roi_coordinates);
%all_roi = [all_roi_coordinates all_roi_names];
csvwrite(coordinate_out,all_roi_coordinates);
fid = fopen(all_names_out,'wt');
for k=1:size(all_roi_names,1)
    fprintf(fid,'%s\n',all_roi_names{k,:});
end
fclose(fid);
%% Build the Euclidean distance matrix
num_rois=length(all_roi_coordinates);
dist_mat=zeros(num_rois,num_rois);
for i=1:num_rois
    for j=1:num_rois
        euc_dist=pdist2(all_roi_coordinates(i,:),all_roi_coordinates(j,:),'euclidean');
        dist_mat(i,j)=euc_dist;
    end
end
savefilename = [output_folder f 'euclidean_distance.mat'];
save(savefilename, 'dist_mat')