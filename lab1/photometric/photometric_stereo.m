clear, clc

% obtain many images in a fixed view under different illumination
[image_stack, W, H] = load_image();

% determine the matrix scriptV from source and camera information
scriptV = get_source(200);

[albedo, normal, p, q] = compute_surface_gradient(image_stack, scriptV);

p(isnan(p)) = 0;
q(isnan(q)) = 0;

% integrability check: is (dp / dy  -  dq / dx) ^ 2 small everywhere?
[dpdy, dqdx] = check_integrability(p, q);

% plot the results
figure(1) 
subplot(2, 2, 1);
[X, Y] = meshgrid(1:512, 1:512);
sqdiff = (dpdy - dqdx).^2;
surf(X, Y, sqdiff, gradient(sqdiff));
title('Integrability check: (dp / dy - dq / dx) ^2 ');

subplot(2, 2, 2);
imshow(albedo);
title('Albedo');

% compute the surface height
height_map = construct_surface( p, q, W, H );

subplot(2, 2, 3);
step_size = 32;
[X_sub, Y_sub] = meshgrid(1:step_size:512, 1:step_size:512);  
surf(X_sub, Y_sub, height_map(1:step_size:end, 1:step_size:end));
xlabel('x'),ylabel('y'),zlabel('z');
title('Surface Mesh');

[U, V, W] = surfnorm(X_sub, Y_sub, height_map(1:step_size:end, 1:step_size:end));
subplot(2, 2, 4), 
quiver3(X_sub, Y_sub, height_map(1:step_size:end, 1:step_size:end), U, V, W, 0.5);
xlabel('x'),ylabel('y'),zlabel('z');
title('Surface normals');
    
