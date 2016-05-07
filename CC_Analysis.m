%% Finding connected component in each of the given training image
% For a.bmp
% for using connected component (bwlabel), we need a binary image

%% Thresholding
function[features]= CC_Analysis(input_char)
a= input_char;
% a= im2double(a);
for i =1 : size(a,1)
    for j=1:size(a,2)
        if(a(i,j)>200)
            a_bin(i,j)=1;
        else
            a_bin(i,j)=0;
        end
    end
end

% a_bin = im2bw(a);
a_bin_inverse= ~a_bin;
[l, num]= bwlabel(a_bin_inverse);

%% Making bounding box

% imshow(l);
hold on;
for i = 1:num
    [r,c]=find(l==i);
    maxr= max(r);
    minr=min(r);
    maxc= max(c);
    minc=min(c);
    rectangle('Position',[minc,minr,maxc-minc+1,maxr-minr+1],'EdgeColor','w'); %    rectangle('Position',[minc,minr,maxc-minc+1,maxr-minr+1],'EdgeColor','w') Take care for scalar 1 for corner elements
     rect.ht(i)= (maxc-minc);
     rect.wt(i)= (maxr-minr);
     rect.coords{i}=  [minc,maxc, minr, maxr];
end
% hold off

%% Using bounding box to remove noise


temp = find(rect.ht<9);
temp = horzcat(temp, find(rect.wt<9));
temp = horzcat(temp, find(rect.wt>100));
temp = horzcat(temp, find(rect.ht>100));






for i = 1:size(temp,2)
    l(l==temp(i))=0;
    rect.coords{temp(i)}=0;
    
end

%% Computing Features
features=[];

for i = 1:size(rect.coords,2)
    if(rect.coords{i}~=0)
        if( rect.coords{i}(1)~=1 && rect.coords{i}(3)~=1 && rect.coords{i}(2)~=size(input_char,2)&& rect.coords{i}(4)~=size(input_char,1) )
            cropped_image=a_bin_inverse((rect.coords{i}(3))-1:(rect.coords{i}(4))+1,(rect.coords{i}(1))-1:(rect.coords{i}(2))+1);
            [centroid,theta,roundness,inmo]= moments(cropped_image,0);
            features=[features;[theta,roundness,inmo]];
        end
    end

end




%% rough
% close all
% figure,imshow(l)