function [ Z ] = applyaffine(X, W, T)

    % Applies the affine transformation given by square matrix W and 
    % translation T to points in X where each column of X is a pair [x_n;
    % y_n]
    
    Z = W * X + T;

end