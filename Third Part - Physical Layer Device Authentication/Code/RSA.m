classdef RSA
    % A class handling RSA encryption, decryption and associated keys
    
    % https://github.com/WilliamManley/RSA-in-MATLAB/
    properties
        public_key_pt1
        public_key_pt2
        private_key
    end
    
    methods
        function r = RSA()
            size=53;
            i=size/2+ceil(rand*4);
            j=size-i;
            p= RSA.generate(i);
            q= RSA.generate(j);
            N=p*q;
            A=65537;
            n=(p-1)*(q-1);
            [~,L,~]=gcd(A,n);
            a=mod(L,n);
            r.public_key_pt1=sym(N);
            r.public_key_pt2=sym(A);
            r.private_key=sym(a);
        end
        
        function f = encrypt(r,m)
            % Encrypts the message 'm' using the RSA public key
            if (m>r.public_key_pt1)
                disp('Error: message must be smaller than N')
            elseif (m<0)
                disp('Error: message must be greater than zero')
            else
                c=expMod(sym(m),r.public_key_pt2,r.public_key_pt1);
                f=c;
            end
        end
        
        function d = decrypt(r,c)
            % Decrypts the cipher 'c' using the RSA private key
            m=expMod(sym(c),r.private_key,r.public_key_pt1);
            d=m;
        end
    end
    
    methods (Static)
        function p = generate(s)
            % Generates a random prime number of 's' bits
            B=0;
            p=0;
            while (B==0)
                if(isprime(p)==false)
                    p=floor(2^(s-1)+rand*2^(s-1));
                else
                    B=1;
                end
            end
        end
    end
end
