function [best_W, best_T] = ransac(F1, F2, M, p)

    N = log(1 - p) / log( 1 - (1 - 0.9) ^ 2);
    max_inliers = 0;
    
    for n=1:N
       
        % Sample one pair of points from both images
        rand_sample = randi(length(M),[3, 1]);
        x = F1(1:2, M(1,rand_sample))';
        x_ = F2(1:2, M(2,rand_sample))';
        
        % Define A and b
        A = zeros(6,6);
        b = zeros(6,1);
        
        for i=1:3
            A(2*i-1:2*i,:) = [x(i,1) x(i,2) 0 0 1 0 ; 0 0 x(i,1) x(i,2) 0 1];
            b(2*i-1:2*i) = [x_(i,1) ; x_(i,2)];
        end
        
        % Solve the linear system for tranformation parameters
        R = (pinv(A) * b)';
        
        % Calculate number of inliers
        W = [R(1) R(2) ; R(3) R(4)];
        T = [R(5) ; R(6)];
        
        % Find errors
        errors = (W * F1(1:2,M(1,:)) + T) - F2(1:2,M(2,:));
        
        % Count inliers
        inliers_count = sum(([1 1] * errors.^2) < 100);
        
        
        if inliers_count > max_inliers
            fprintf('Num of inliers %d\n', inliers_count);
            max_inliers = inliers_count;
            best_W = W;
            best_T = T;
        end
    end
end

