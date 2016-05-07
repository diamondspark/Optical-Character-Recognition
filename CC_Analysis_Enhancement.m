%% Finding connected component in each of the given training image
% For a.bmp
% for using connected component (bwlabel), we need a binary image

%% Thresholding
function[features]= CC_Analysis_Enhancement(input_char)
a = input_char;
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


% remove cc's near edges

for i = 1:10
    for j = 1: size(l,2)
        if(l(i,j)~=0)
            cc_num = l(i,j);
            cc_num_loc = find(l==cc_num);
            l(cc_num_loc)=0;
        end
    end
end



for i = size(l,1)-10: size(l,1)
    for j = 1: size(l,2)
        if(l(i,j)~=0)
            cc_num = l(i,j);
            cc_num_loc = find(l==cc_num);
            l(cc_num_loc)=0;
        end
    end
end
        

for j = 1:10
    for i = 1:size(l,1)
        if(l(i,j)~=0)
            cc_num = l(i,j);
            cc_num_loc = find(l==cc_num);
            l(cc_num_loc)=0;
        end
    end
end


for j = size(l,2)-10: size(l,2)
    
    for i = 1:size(l,1)
        if(l(i,j)~=0)
            cc_num = l(i,j);
            cc_num_loc = find(l==cc_num);
            l(cc_num_loc)=0;
        end
    end
end
        


se = strel('disk',1);
l_new = imdilate(l,se);
[l, num]= bwlabel(l_new);
% [l, num]= bwlabel(l);
      

%% Making bounding box

for i = 1:num
    [r,c]=find(l==i);
    maxr= max(r);
    minr=min(r);
    maxc= max(c);
    minc=min(c);

     rect.ht(i)= (maxc-minc);
     rect.wt(i)= (maxr-minr);
     rect.coords{i}=  [minc,maxc, minr, maxr];
end

%% Using bounding box to remove noise


temp = find(rect.ht<9);
temp = horzcat(temp, find(rect.wt<9));







for i = 1:size(temp,2)
    l(l==temp(i))=0;
    rect.coords{temp(i)}=0;
    
end



% final l
[l_final, num] = bwlabel(l);

%% 

%  figure,imshow(l_final),title('Connected Components with bounding boxes');
% hold on;
for i = 1:num
    [r,c]=find(l_final==i);
    maxr= max(r);
    minr=min(r);
    maxc= max(c);
    minc=min(c);
    %Enable to draw bounding boxes
     rectangle('Position',[minc,minr,maxc-minc+1,maxr-minr+1],'EdgeColor','w');
     
end
%  hold off


%% Computing Features
% figure,imshow(l_final)
features=[];

for i = 1:size(rect.coords,2)
    if(rect.coords{i}~=0)
%         if( rect.coords{i}(1)~=1 && rect.coords{i}(3)~=1 && rect.coords{i}(2)~=size(input_char,2)&& rect.coords{i}(4)~=size(input_char,1) )
            cropped_image=a_bin_inverse((rect.coords{i}(3))-0:(rect.coords{i}(4))+0,(rect.coords{i}(1))-0:(rect.coords{i}(2))+0);
           
%           figure,   imshow(cropped_image),title('cropped image')
            cropped_image_after = imresize(cropped_image,[30,30]);
            [centroid,theta,roundness,inmo]= moments(cropped_image_after,0);
            hold off
            
            squish = reshape(cropped_image_after,[1,size(cropped_image_after,1)*size(cropped_image_after,2)]);
           
            
            kurt= kurtosis(squish);
            skew = skewness(squish);
            BW = cropped_image_after;
            BW2=imfill(BW,'holes');
            area=regionprops(BW2-BW,'area');
            peri = regionprops(cropped_image_after,'Perimeter');
            major_axis_lt = regionprops(cropped_image_after,'MajorAxisLength');
            minor_axis_lt = regionprops(cropped_image_after,'MinorAxisLength');
            orient= regionprops(cropped_image_after,'Orientation');
%           
            
            
           if(size(area,1~=0))
            holes = area.Area(1);
           else
               holes=0;
           end
          
           
           features=[features;[centroid, theta,roundness,inmo,kurt,skew,holes,peri(1).Perimeter,major_axis_lt(1).MajorAxisLength,minor_axis_lt(1).MinorAxisLength,orient(1).Orientation]];
    end
    

end




%% rough
% close all
%  figure,imshow(l)