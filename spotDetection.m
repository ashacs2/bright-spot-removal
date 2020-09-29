 
clear;
close all;
clc;
%% Load reference image, and compute surf features
% ref_img = imcrop(imread('Images/img07.jpeg'));
%imwrite(ref_img,'bit.jpg');
% print([figPath 'dataset ' num2str(idxA) '_' num2str(idxC)], '-depsc','-r600');
% print([figPath 'dataset ' num2str(idxA) '_' num2str(idxC)], '-dpng','-r600');
figPath='.\OutputSURFTV\'
ref_img=imread('bit.jpg');
[k,l]=size(ref_img);
ref_img_gray = rgb2gray(ref_img);
ref_pts = detectSURFFeatures(ref_img_gray);
[ref_features,  ref_validPts] = extractFeatures(ref_img_gray,  ref_pts);
printImg();
figure; imshow(ref_img);
print([figPath 'sample'], '-dpng','-r600');
hold on; plot(ref_pts.selectStrongest(5));
%% Compare to video frame
no=231;
image = imread(['Images/images/img',num2str(no),'.jpg']);
printImg();
figure;imshow(image);
print([figPath 'original' num2str(no)], '-dpng','-r600');
%%
I = rgb2gray(image);
% Detect features
I_pts = detectSURFFeatures(I);
[I_features, I_validPts] = extractFeatures(I, I_pts);
printImg();figure;imshow(image);
hold on; plot(I_pts.selectStrongest(5));
print([figPath 'originalFeatures' num2str(no)], '-dpng','-r600');
%% Compare card image to video frame
index_pairs = matchFeatures(ref_features, I_features);
ref_matched_pts = ref_validPts(index_pairs(:,1)).Location;
I_matched_pts = I_validPts(index_pairs(:,2)).Location;
% figure, showMatchedFeatures(image, ref_img, I_matched_pts, ref_matched_pts, 'montage');
% title('Showing all matches');
%% Define Geometric Transformation Objects
strongest = I_matched_pts;
[hog2, validPoints, ptVis] = extractHOGFeatures(image,strongest);
printImg();
figure;imshow(image); hold on;plot(ptVis,'Color','green');
print([figPath 'originalSURF' num2str(no)], '-dpng','-r600');
x1=double(strongest(1,1)-10);
x2=double(strongest(1,1)+10);
y1=double(strongest(1,2)-10);
y2=double(strongest(1,2)+10);
%% 
% Convert from RGB to grayscale.
X = rgb2gray(image);
% Create empty mask.
BW = zeros(size(X));
BW(y1:y2,x1:x2)=double(1);
%%
% Create masked image.
maskedImage = X;
maskedImage(~BW) = 0;
%%
bw=im2bw(image,0.5);
figure; imshow(bw);
out=BW & bw;
%%
printImg();
figure;imshow(out);
print([figPath 'mask' num2str(no)], '-dpng','-r600');
im=image;
patch_size = 21;
SE=strel('disk',1);
target_mask = imdilate(out,SE); 
printImg();
figure;imshow(target_mask);
print([figPath 'maskDilated' num2str(no)], '-dpng','-r600');
mask(:,:,1)=target_mask;
mask(:,:,2)=target_mask;
mask(:,:,3)=target_mask;
tic;
out=hole_filling_crimnisi(im2single(im), (target_mask), patch_size, 0.01, 'river');

% hsv=rgb2lab(im);
% hsv(:,:,1)=TVpaint(hsv(:,:,1),target_mask);
% out=lab2rgb(hsv);
toc;

figure;imshow(out);
print([figPath 'final' num2str(no)], '-dpng','-r600');

