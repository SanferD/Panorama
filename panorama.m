function [] = panorama()
    fx = 5*45;
    fy = 5*85;
	width = 640;
	height = 480;
	px = width/2;
	py = height/2;
	K = [fx 0 px; 0 fy py; 0 0 1];

	numOfImages = 10;

	panoramaWidth = 1500;
	panoramaHeight = height;
	numberOfImageChannels = 3;
	panorama = zeros(panoramaHeight, panoramaWidth, numberOfImageChannels);
	panorama = double(panorama);
	pixelCount = zeros(size(panorama));
	pixelCount = uint32(pixelCount);

	dimsOfRotationMatrix = 3;
	transformGenerator = TransformGenerator(dimsOfRotationMatrix, numOfImages, K);
	transformGenerator.GenerateTransforms();
    f = sqrt(fx*fx + fy*fy);
    
    % while 1
    % 	for i=1:10
    % 		i
    		% Special(transformGenerator, 6);
    		% pause(.5);
    % 	end
    % end
    % return
	for n = 1:numOfImages
		im = GetImage(n);
		R = transformGenerator.GetRotation(n);
		R = inv(R);

		for h = 1:panoramaHeight
			for w = 1:panoramaWidth

				theta = (w/panoramaWidth)*2*pi - (2*pi/numOfImages);
				p = [ f*sin(theta); h - panoramaHeight/2; f*cos(theta) ];
				imageCoord = K*R*p;
				imageCoord = imageCoord/imageCoord(3);
				
				if R(3, :)*p > 0
					i = floor(imageCoord(2));
					j = floor(imageCoord(1));
		    	    if i>0 && i<=height && j>0 && j<=width
						panorama(h, w, :) = panorama(h, w, :) + double(im(i, j, :));
						pixelCount(h, w, :) = pixelCount(h, w, :) + uint32(ones(1,1,3));
					end
				end
			end
		end
	end
	
	imshow(uint8(round(panorama./double(pixelCount))));
end

function im = GetImage(n)
	imageName = sprintf('ImageSequence/%i.jpg', n);
	im = imread(imageName);
	im = uint32(im);
end

function im_warped = ImageWarping(im, H)

    im = double(im);
    H = inv(H);

    [u_x, u_y] = meshgrid(1:(size(im,2)), 1:(size(im,1)));
    h = size(u_x, 1); w = size(u_x,2);

    v_x = H(1,1)*u_x + H(1,2)*u_y + H(1,3);
    v_y = H(2,1)*u_x + H(2,2)*u_y + H(2,3);
    v_z = H(3,1)*u_x + H(3,2)*u_y + H(3,3);

    v_x = v_x./v_z;
    v_y = v_y./v_z;

    im_warped(:,:,1) = reshape(interp2(im(:,:,1), v_x(:), v_y(:)), [h, w]);
    im_warped(:,:,2) = reshape(interp2(im(:,:,2), v_x(:), v_y(:)), [h, w]);
    im_warped(:,:,3) = reshape(interp2(im(:,:,3), v_x(:), v_y(:)), [h, w]);

    im_warped = uint8(im_warped);
end

function Special(transformGenerator, n)
    im1 = GetImage(n);
    if n+1 == 11
    	im2 = GetImage(1);
    else
    	im2 = GetImage(n+1);
    end
    
	H = transformGenerator.GetHomography(n+1);
    warped = ImageWarping(im2, H);
    
    scale1 = 0.5;
    scale2 = 1 - scale1;
    result = scale1*double(im1) + scale2*double(warped);
    imshow([uint8(result)])
end