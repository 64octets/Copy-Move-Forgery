function [ output_args ] = detectCopyMove( im,b )
%The function can be used to detect copy move regions in digital images as a
%forgery detection technique we use radon transform to obtain invariant
%features which are invariant to content preserving operations.
%we store original(rgb/grayscale) image in a variable
im=imresize(im,[256 256]);
original=im;
%we extract the dimension, height(number of rows), width(number of columns)
[m,n,d]=size(im);
%if dimension is greater than 1 we convert to grayscale
if d>1
    display('Converting to grayscale image.');
    im=rgb2gray(im);
end
%for block size b, we will  have (m-b+1)*(n-b+1) number of rows in the
%feature matrix as the block b slides 1 pixel at a time over the grayscale
%image
numberOfRows=(m-b+1)*(n-b+1);
fprintf('Total Number of rows in Feature Matrix is %d\n',numberOfRows);
%preallocation of feature matrix
feature=zeros(numberOfRows,17);
index=1;
display('Generating feature matrix...')
tic
%making the block slide over the entire image and for each block compute
%DFT coefficients
for i=1:1:m-b+1
    for j=1:1:n-b+1
        block=im(i:i+b-1,j:j+b-1);
        %extract DFT coefficients of each block
        coefficients=extractCoefficientUsingRadon(block);
        %append DFT coefficients of each block to the feature matrix
        feature(index,1:15)=coefficients;
        %also get topmost left coordinate for each block
        feature(index,16:17)=[i, j];
        index=index+1;
    end
end
toc
%lexicographically sort the feature matrix
display('Sorting...')
feature=sortrows(feature,1:15);
%store locations and features in two seperate matrices
display('Seperating...')
loc=feature(:,16:17);
feature=feature(:,1:15);
display('Done. Locations and Features in seperate matrices.');
%preallocating shift vector, Match1, Match2
shift_vector= zeros(numberOfRows,2);
match1= zeros(numberOfRows,2);
match2= zeros(numberOfRows,2);
num_match_index=1;
% no of comparisons to find matching blocks
display('Comparing consecutive rows in feature matrix.');
for current=1:numberOfRows-1                                             
    next=current+1;
    % distance for matching blocks using hamming distance
    d=sum(abs(feature(current,:)-feature(next,:)))/1023;
    %if hamming distance is less than threshold we say blocks are matching
    if d<.05
        % for matching blocks extract the coordinates from loc matrix
        x1y1=loc(current,:);
        x2y2=loc(next,:);
        % compute the shift vector between matching blocks
        shift_vector(num_match_index,:) = abs(x1y1-x2y2); 
        %only if matching blocks are seperated by a shift vector not equal
        %to i.e greater than [0, 1],[1, 0],[1, 1]
        if sum(shift_vector(num_match_index,:))>4%(~isequal(shift_vector(num_match_index,:), [0,2]) && ~isequal(shift_vector(num_match_index,:), [2,0]) && ~isequal(shift_vector(num_match_index,:), [2,2]))
            match1(num_match_index,:)=x1y1;
            match2(num_match_index,:)=x2y2;
            num_match_index=num_match_index+1;
        end
    end
end
%downsizing
match1 = match1(1:num_match_index-1, :)                           
match2 = match2(1:num_match_index-1, :)
shift_vector = shift_vector(1:num_match_index-1, :)
%shift_vector now contains those shifts whose corresponding matching blocks
%are at a distance greater than threshold to minimize false positives
%and Match1 and Match2 contain the coordinates of the blocks corresponding
%to those shifts
display('Shift vector and Match 1, Match 2 generated.');
%compute the unique shifts and the number of times these shifts occur
[unique_shifts,~,ind] = unique(shift_vector,'rows');
counts = histc(ind,unique(ind));
%preallocation
indices=zeros(1,length(shift_vector));
k=1;
imshow(original)
hold on
for index=1:length(counts)
    if counts(index)>5
        %for those unique shifts having counts greater than 5
        temp=unique_shifts(index,:);
        %and from shift_vector return all the indices when element==temp
        for indx=1:length(shift_vector)
            if shift_vector(indx,:)==temp
                indices(k)=indx;
                k=k+1;
            end
        end
        %downsizing
        indices=indices(1:k-1);
        for anotherIndex=1:length(indices)
            anotherTemp=indices(anotherIndex);
            x1=match1(anotherTemp,1);
            y1=match1(anotherTemp,2);
            x2=match2(anotherTemp,1);
            y2=match2(anotherTemp,2);
            rectangle('Position', [x1,x1+b-1,y1,y1+b-1],'EdgeColor','r', 'LineWidth', 2)
            rectangle('Position', [x2,x2+b-1,y2,y2+b-1],'EdgeColor','r', 'LineWidth', 2)
        end
    end
end
       
end

