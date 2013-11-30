clear all;
M_train = csvread('C:\Users\Utkarsh\AppData\Roaming\MediaMonkey\genre-new.csv');
M_test = csvread('C:\Users\Utkarsh\AppData\Roaming\MediaMonkey\genre_test.csv');

train = M_train(:,1:14);
labels = M_train(:,15);
test = M_test(:,1:14); 

% %Naive Bayes
obj = NaiveBayes.fit(train, labels);
cls = obj.predict(test);
MID = size(train, 1);
UPPER = size(train, 1)+size(test, 1);
disp(cls);
write(1:MID,:) = [train labels];
write(MID+1:UPPER,:) = [test cls]; 
csvwrite('C:\Users\Utkarsh\AppData\Roaming\MediaMonkey\genre-new.csv', write);
test_labels = M_test(:, 15);
cMatnb = confusionmat(test_labels, cls);
disp('Confusion Matrix for Naive Bayes:');
disp(cMatnb);

%SVM
result = multisvm(train, labels, test);
cMatsvm = confusionmat(test_labels, result);
disp('Confusion Matrix for MultiClass SVM:');
disp(cMatsvm);

% % compare = [test_labels result];
% % disp(compare);
% out = [M_test cls];
% % fid = fopen('C:\cls) 
% %     fprintf(fid, '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%d\n', out(i)); 
% % endUsers\Viraj\Desktop\ML Project\genre_test.csv', 'at');
% % for i=1:size(
% 
% % final = [M_test cls];
% % csvwrite('genre_test.csv', final);
% 
% % fid = fopen('genre_test_unlabelled.csv','a');
% % csvwrite ('genre_test_unlabelled.csv',result);
% % status = fclose('all');
% fclose(fid);
%K-means
[IDX, C] = kmeans(train, 4);
%disp(IDX);

plot(train(IDX==1,1),train(IDX==1,2),'r.','MarkerSize', 12)
hold on
plot(train(IDX==2,1),train(IDX==2,2),'b.','MarkerSize', 8)
hold on
plot(train(IDX==3,1),train(IDX==3,2),'g.','MarkerSize', 8)
hold on
plot(train(IDX==4,1),train(IDX==4,2),'c.','MarkerSize', 8)

% cp = cvpartition(
% vals = crossval('mcr', M_train,M_test,'Predict', );
% disp(vals);