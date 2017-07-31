classdef TransformGenerator < handle

	properties (Access = private)
		allRotations;
		allHomographies;
		rows;
		K;
		numOfMatrices;
	end

	methods

		function obj = TransformGenerator(rows, n, K)
			obj.rows = rows;
			obj.allRotations = eye(rows, rows*n);
			obj.allHomographies = eye(rows, rows*n);
			obj.K = K;
			obj.numOfMatrices = n;
		end

		function GenerateTransforms(obj)
			for i = 2:(obj.numOfMatrices+1)
				obj.GenerateTransform(i);
			end
		end

		function R = GetRotation(obj, n)
			[first, last] = obj.GetFirstLastIndexFromN(n);
			R = obj.allRotations(:, first:last);
		end

		function H = GetHomography(obj, n)
			[first, last] = obj.GetFirstLastIndexFromN(n);
			H = obj.allHomographies(:, first:last);
		end

	end

	methods (Access = private)

		function GenerateTransform(obj, n)
			[pointsFrom, pointsTo] = GetPointsForHomography(n-1);
			[H, R] = obj.GetGeometricTransforms(pointsFrom, pointsTo);
			[prevFirst, prevLast] = obj.GetFirstLastIndexFromN(n-1);
			[first, last] = obj.GetFirstLastIndexFromN(n);
			obj.allHomographies(:, first:last) = H;%*obj.allHomographies(:, prevFirst:prevLast);
			obj.allRotations(:, first:last) = R*obj.allRotations(:, prevFirst:prevLast);
		end

		function [H, R] = GetGeometricTransforms(obj, u, X)
		    K = obj.K;
			H = obj.ComputeHomography(u, X);
		    H = H/H(3,3);
		    R = inv(K)*H*K;
 			lambda = 1/det(R)^(1/3);
            R = lambda*R;
        end

		function H = ComputeHomography(obj, u, X)
			A = [];
			for i = 1 : size(u,1)
			    A = [A; X(i,:) zeros(1,3) -u(i,1)*X(i,:)];
			    A = [A; zeros(1,3) X(i,:) -u(i,2)*X(i,:)];
			end

			[u, d, v] = svd(A);
			h = v(:,end);
			H = [h(1:3)'; h(4:6)'; h(7:9)'];
			H = H/norm(H);
		end

		function [first, last] = GetFirstLastIndexFromN(obj, n)
			first = (n-1)*obj.rows + 1;
			last = n*obj.rows;
		end

	end

end
 