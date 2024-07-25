function exitcode = solveStackelbergGame(B, C, w_c, varrho_c, eta_c)
    C_set=1:C;

    Solved = false;

    while Solved == false

        aux=sum(sqrt(w_c(C_set).*varrho_c(C_set)./eta_c(C_set)))...
            /(B+sum(varrho_c(C_set)./eta_c(C_set)));

        p_c(C_set)=aux*sqrt(eta_c(C_set).*w_c(C_set)./varrho_c(C_set));

        B_c(C_set)=w_c(C_set)./p_c(C_set)...
            -varrho_c(C_set)./eta_c(C_set);

        if ~isempty(find(B_c(C_set)<0, 1))

            [~,cp]=min(B_c(:));

            C_set=setdiff(C_set,cp);

            B_c(cp)=0;

            p_c(cp)=0;

        else

            Solved=true;

        end
    end

    fprintf('[%s]\n', join(string(p_c), ','));
    fprintf('[%s]\n', join(string(B_c), ','));
    exitcode = 0;
end 
