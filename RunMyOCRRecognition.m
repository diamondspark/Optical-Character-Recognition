function [ predicted_final ] = RunMyOCRRecognition( filename, location,classes )
diary on
close all

a = imread(filename);
%% Base case Training and testing
 Output_Extract_Features;
       
        testing_ocr; 


%% 
Enhancement;
%% Enhancement Testing
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

%  figure,imshow(l),title('Connected Components with bounding boxes');

for i = 1:num
    [r,c]=find(l==i);
    maxr= max(r);
    minr=min(r);
    maxc= max(c);
    minc=min(c);
%          rectangle('Position',[minc,minr,maxc-minc+1,maxr-minr+1],'EdgeColor','w') Take care for scalar 1 for corner elements
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



%% final l
[l_final, num] = bwlabel(l);

%% drawing Bounding box for display
%  figure,imshow(l_final),title('Connected Components with bounding boxes');
hold on;
for i = 1:num
    [r,c]=find(l_final==i);
    maxr= max(r);
    minr=min(r);
    maxc= max(c);
    minc=min(c);
    rectangle('Position',[minc,minr,maxc-minc+1,maxr-minr+1],'EdgeColor','w');
     
end
 hold off

figure





%% Computing Features
% figure,imshow(l_final)


p=[];
j=1;
for i = 1:size(rect.coords,2)
    if(rect.coords{i}~=0)
        rect.coords_final{j}= rect.coords{i};
        j=j+1;
%         if( rect.coords{i}(1)~=1 && rect.coords{i}(3)~=1 && rect.coords{i}(2)~=size(input_char,2)&& rect.coords{i}(4)~=size(input_char,1) )
            cropped_image=a_bin_inverse((rect.coords{i}(3))-0:(rect.coords{i}(4))+0,(rect.coords{i}(1))-0:(rect.coords{i}(2))+0);
%             figure, imshow(cropped_image)
           
%             [centroid,theta,roundness,inmo]= moments(cropped_image,0);
          
            
            
            
%         figure,   imshow(cropped_image),title('cropped image')
       cropped_image_after = imresize(cropped_image,[30,30]);
%        figure, imshow(cropped_image_after);
[centroid,theta,roundness,inmo]= moments(cropped_image_after,0);
           squish = reshape(cropped_image_after,[1,size(cropped_image_after,1)*size(cropped_image_after,2)]);
            kurt= kurtosis(squish);
            skew = skewness(squish);
   
            %% 
             BW = cropped_image_after;
            BW2=imfill(BW,'holes');
            area=regionprops(BW2-BW,'area');
        
        %%
            if(size(area,1~=0))
            holes = area.Area(1);
           else
               holes=0;
            end
           
            
            peri = regionprops(cropped_image_after,'Perimeter');
            major_axis_lt = regionprops(cropped_image_after,'MajorAxisLength');
            minor_axis_lt = regionprops(cropped_image_after,'MinorAxisLength');
            orient= regionprops(cropped_image_after,'Orientation');
            
            
            
                p=[p;[centroid, theta,roundness,inmo,kurt,skew,holes,peri(1).Perimeter,major_axis_lt(1).MajorAxisLength,minor_axis_lt(1).MinorAxisLength,orient(1).Orientation]];            
    
    end
end


%% Normalize
for i = 1:size(p,1)
p(i,:) = p(i,:)-average;
end
for i = 1: size(p,1)
p(i,:)= p(i,:)./stand_dev;
end

%% Prediction

D = dist2(p,features);
[D_sorted, D_index] = sort(D, 2);

figure, imagesc(D), title('Distance matrix');

submatrix = D_index(:,1);
prediction=[];
for i = 1:size(submatrix,1)
     prediction = vertcat(prediction,label(submatrix(i)));
end







%%  
predicted_final=[];
never_found_pts=[];
for i = 1 : size(location,1)
    flag=0;
    
     x_cor= location(i,1);
        y_cor= location(i,2);
    
    for j = 1: size(rect.coords_final,2)
        
       
        xv= [rect.coords_final{j}(1);rect.coords_final{j}(1);rect.coords_final{j}(2);rect.coords_final{j}(2)];
        yv=[ rect.coords_final{j}(3);rect.coords_final{j}(4);rect.coords_final{j}(4);rect.coords_final{j}(3)];
        
        in = inpolygon(x_cor,y_cor,xv,yv);
        if(in==1)
            predicted_final=vertcat(predicted_final,prediction(j));
            flag=1;
            break;
        
           
        end
    end
    
    if(flag==0)
     never_found_pts= vertcat(never_found_pts,location(i,:));
    end
end
if(size(predicted_final,1)==size(classes,1))
    acc= find((predicted_final-classes)==0);
    test_accuracy_enhancement = size(acc,1)/size(classes,1)
end


figure,imshow(a), title('With Enhancement')
for i = 1 : size (predicted_final,1)
    Write_on_image_blue(location(i,:),predicted_final(i));
end

diary off
end