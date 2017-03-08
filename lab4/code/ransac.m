function [best_W, best_T] = ransac(F1, F2, M, p)

    N = log(1 - p) / log( 1 - (1 - 0.9) ^ 2)
    max_inliers = 0;
    
    for n=1:N
       
        % Sample one pair of points from both images
        rand_sample = randi(length(M),[1, 1]);
        x = F1(1:2, M(1,n))';
        x_ = F2(1:2, M(2,n))';
        
        % Define A and b
        A = [x(1) x(2) 0 0 1 0 ; 0 0 x(1) x(2) 0 1];
        b = [x_(1) ; x_(2)];
        
        % Solve the linear system for tranformation parameters
        R = (pinv(A) * b)';
        
        % Calculate number of inliers
        W = [R(1) R(2) ; R(3) R(4)];
        T = [R(5) ; R(6)];
        
        % Find errors
        errors = (W * F1(1:2,M(1,:)) + T) - F2(1:2,M(2,:));
        
        % Count inliers
        inliers_count = sum(([1 1] * errors.^2) < 500);
        
        if inliers_count > max_inliers
            fprintf('Num of inliers %d\n', inliers_count);
            max_inliers = inliers_count;
            best_W = W;
            best_T = T;
        end
    end
end
