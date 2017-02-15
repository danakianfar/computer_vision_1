function [mu, med, sigma] = stats4jesus(vector)
    mu = mean(vector);
    sigma = std(vector);
    med = median(vector);
end

