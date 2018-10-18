function cohensKappa = getCohensKappa(class1, class2)
%%% Cohen's Kappa values between class vectors classTrue and classEstim
%
% Copyright (C) Thilo Weber 2018 (see MIT license in the README.txt file)
%
% Output:
%   @cohens_kappa: array of kappa values (length = m+1, where m is the
%   number of different classes)
%       1 - for all classes together
%       2 - "first class" against "not first class"
%       3 - "second class" against "not second class"
%       ...
%       m - "m-th class" against "not m-th class"
%
% This function is implemented following: https://de.wikipedia.org/wiki/Cohens_Kappa
%


dataLen = length(class1);
m = max(max(class1), max(class2));

cohensKappa = zeros(m+1,1);

% Probability table for calculating Cohen's Kappa:
classProbTable = zeros(m);
for k=1:dataLen
    classProbTable(class1(k), class2(k)) = ...
        classProbTable(class1(k), class2(k)) + 1;
end
classProbTable = classProbTable / dataLen;

% Calculate Cohen's Kappa for all classes:
p_0 = sum(diag(classProbTable));
p_c = sum(classProbTable,1) * sum(classProbTable,2);
cohensKappa(1) = (p_0 - p_c) / (1 - p_c);

% Calculate Cohen's Kappa for each classes i against all other classes:
class_prob_table_i = zeros(2);
for i=1:m
    class_prob_table_i(1,1) = classProbTable(i,i);
    class_prob_table_i(1,2) = sum(classProbTable(i,[1:i-1 i+1:m]));
    class_prob_table_i(2,1) = sum(classProbTable([1:i-1 i+1:m],i));
    class_prob_table_i(2,2) = sum(sum(classProbTable([1:i-1 i+1:m],[1:i-1 i+1:m])));
    
    p_0 = sum(diag(class_prob_table_i));
    p_c = sum(class_prob_table_i,1) * sum(class_prob_table_i,2);
    cohensKappa(i+1) = (p_0 - p_c) / (1 - p_c);
end

end

