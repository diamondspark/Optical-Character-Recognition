
input_char=a;
for i =1 : size(a,1)
    for j=1:size(a,2)
        if(a(i,j)>200)
            a_bin(i,j)=1;
        else
            a_bin(i,j)=0;
        end
    end
end


a_bin_inverse= ~a_bin;
[l, num]= bwlabel(a_bin_inverse);

%% Making bounding box

figure, imshow(l), title('Connected Components and Bounding Box Testing');
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
 hold off

%% Using bounding box to remove noise


temp = find(rect.ht<9);
temp = horzcat(temp, find(rect.wt<9));
temp = horzcat(temp, find(rect.wt>100));
temp = horzcat(temp, find(rect.ht>100));






for i = 1:size(temp,2)
    l(l==temp(i))=0;
    rect.coords{temp(i)}=0;
    
end


j=1;
p=[];
for i = 1:size(rect.coords,2)
    if(rect.coords{i}~=0)
        rect.coords_final{j}= rect.coords{i};
        j=j+1;
        if( rect.coords{i}(1)~=1 && rect.coords{i}(3)~=1 && rect.coords{i}(2)~=size(input_char,2)&& rect.coords{i}(4)~=size(input_char,1) )
            cropped_image=a_bin_inverse((rect.coords{i}(3))-1:(rect.coords{i}(4))+1,(rect.coords{i}(1))-1:(rect.coords{i}(2))+1);
            close all
            imshow(cropped_image)
            [centroid,theta,roundness,inmo]= moments(cropped_image,0);
            p=[p;[theta,roundness,inmo]];
        end
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

submatrix = D_index(:,1);
prediction=[];
for i = 1:size(submatrix,1)
     prediction = vertcat(prediction,label(submatrix(i)));
end

figure, imagesc(D), title('Distance Matrix Testing');

%% 
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
    test_accuracy_base = (size(acc,1)/size(classes,1))*100
end

close all
imshow(a)
for i = 1 : size (predicted_final,1)
    Write_on_image_blue(location(i,:),predicted_final(i));
end

