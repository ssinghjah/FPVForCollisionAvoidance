function validRoot = getValidTc(roots)
  validRoot=-1;
    for root = roots
        if root > 0
            validRoot = root;
        end
    end
end

