
diary on
load('train_letters');
features={};
label=[];

features=[];
for i = 1:16
   
    incoming_feat = CC_Analysis_Enhancement(train_letters{i});
    num = size(incoming_feat,1);
    features= vertcat(features,incoming_feat);
    label = vertcat(label, i*ones(num,1));
end


%% Normalize


average=[]; stand_dev=[];

    average = mean(features,1);
    stand_dev= std(features,1);


%% Normalization

for i = 1:size(features,1)
features(i,:) = features(i,:)-average;
end
for i = 1: size(features,1)
features(i,:)= features(i,:)./stand_dev;
end



D = dist2(features, features);
[D_sorted, D_index] = sort(D, 2);



%% Prediction
submatrix = D_index(:,2);
prediction=[];
for i = 1:size(submatrix,1)
     prediction = vertcat(prediction,label(submatrix(i)));
end

%% Confusion matrix
conf = ConfusionMatrix(label, prediction,16);
train_accuracy_enhancement = trace(conf)/sum(sum(conf))