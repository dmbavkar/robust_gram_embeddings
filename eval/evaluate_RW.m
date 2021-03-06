function [rhoArr, simArr] = evaluate_RW(vecs, weights)

%Accessing global searchmap for word filtering queries
global searchmap;
global vocab;

%Batchsize for checking similarities
split_size = 100;

%Load word indexes and similarities (filtered by vocab)
[ind1, ind2, humAvgSim, maxNumQuestions] = loadRW(['data/rw/' 'rw.txt']);

num_iter = ceil(length(ind1)/split_size);
avgsims = [];
maxsims = [];

%Unit normalize for fast cosine distance
W = normr(vecs);

for jj=1:num_iter

    range = (jj-1)*split_size+1:min(jj*split_size,length(ind1));
    avgsims(range,1) = 0;
    maxsims(range,1) = 0;

    if size(W,3) == 1
        avgsims(range,1) = sum(W(ind1(range),:) .* W(ind2(range),:), 2);
    else

        for w = 1 : length(range)
            for m1 = 1 : size(W,3)
                    cosD = W(ind1(range(w)),:,m1) * W(ind2(range(w)),:,m1)';
                    %cosD = cosD + weights(ind1(range(w)),m1) + weights(ind2(range(w)),m2);
                    avgsims(range(w),1) = avgsims(range(w),1) +  cosD;
                    maxsims(range(w),1) = max([maxsims(range(w),1) cosD]);
            end
        end
        avgsims(range,1) = avgsims(range,1) / (size(W,3)*size(W,3));
    end
end

[rho, pval] = corr(humAvgSim,avgsims,'Type','Spearman');
rhoArr(1) = rho;
simArr(1,:) = avgsims;
fprintf('Spearman C. (Avg) on RW: %f QuestionsSeen: (%d/%d) \n', rho, length(ind1), maxNumQuestions);

if size(W,3) > 1
    [rho, pval] = corr(humAvgSim,maxsims,'Type','Spearman');
    rhoArr(2) = rho;
    simArr(2,:) = maxsims;
    fprintf('Spearman C. (Max) on RW: %f QuestionsSeen: (%d/%d) \n', rho, length(ind1), maxNumQuestions);

end

plotPairs = 0;
if plotPairs
    %for i = 1 : length(ind1)
    %   fprintf('%d %s %s \t %f \n', i, vocab{1,1}{ind1(i)}, vocab{1,1}{ind2(i)}, avgsims(i) );
    %end

    for i = 1 : length(ind1)
       fprintf('%d %s %s \t %f \n', i, vocab{1,1}{ind1(i)}, vocab{1,1}{ind2(i)}, maxsims(i) );
    end
end

end
