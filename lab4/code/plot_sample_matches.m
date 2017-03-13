function [f1_selection, f2_selection] = plot_sample_matches( left, right, M, F1, F2, S)

    % Randomly sample 50 matches
    rand_sample = randi(length(M),[S, 1]);
    f1_selection = F1(:,M(1,rand_sample));
    f2_selection = F2(:,M(2,rand_sample)) + [size(left,2);0;0;0];

    % Plot images
    figure
    imshow([left right]);
    hold on

    % Plot descriptors
    vl_plotframe(f1_selection); % left image
    vl_plotframe(f2_selection); % right image

    % Plot random subset of all matching points
    plot([f1_selection(1,:) ; f2_selection(1,:)], [f1_selection(2,:) ; f2_selection(2,:)], 'y-')
    title('Random match samples from UBCMATCH', 'FontSize', 16);
    hold off
end