function [Trans,CollisionNum] = MyTraceCombined(NumParticles,TransProb1,TransProb2)
%returns 1 if transmitted and 0 if not + number of collisions
load SurfaceData
Trans = zeros(1,NumParticles);
for pp = 1:NumParticles
    
    UnitCellTravelled = [0 0];
    Particle.Position = [-UnitCell(1)/2, UnitCell(2)*rand(1) - UnitCell(2)/2];
    angle = asin(-2*rand(1)+1); 
    Direction = [cos(angle) sin(angle)];
    
    CollisionNum(pp) = 0;
    qnt = 0;

    while 0 <= UnitCellTravelled(1) &&  UnitCellTravelled(1) < SimulationLength
    qnt = qnt + 1;
    Particle.Direction= Direction.*ones(length(SurfaceNormals),2);
    cosine = sum((SurfaceNormals.*Particle.Direction),2);
    DistanceToCollision = (SurfaceDisplacements-sum(SurfaceNormals.*(Particle.Position.*ones(length(SurfaceNormals),2)),2))./cosine;
    CollisionPosition = Particle.Position+Particle.Direction.*DistanceToCollision;
    dotproduct = sum((P2-CollisionPosition).*(P1-CollisionPosition),2);
    Intersect = dotproduct < 0;
    DistanceToCollision = DistanceToCollision./Intersect;
    Positive = DistanceToCollision > 0;
    DistanceToCollision = DistanceToCollision./Positive;
    [CollidedDistance,SurfaceNumber] = sort(abs(DistanceToCollision));
    if CollidedDistance(1) < 10^-10
        CollidedDistance = CollidedDistance(2);
        SurfaceNumber = SurfaceNumber(2);
    else
        CollidedDistance = CollidedDistance(1);
        SurfaceNumber = SurfaceNumber(1);
    end

    %%
    %Data(qnt,:) = [Particle.Position,Particle.Position + Direction*CollidedDistance,Direction,CollidedDistance];

    if SurfaceNumber < 5
        Particle.Position = Particle.Position + Direction*CollidedDistance;
%        Direction =  Direction - 2*cosine(SurfaceNumber)*SurfaceNormals(SurfaceNumber,:); 
        Particle.Position = Particle.Position + SurfaceNormals(SurfaceNumber,:).*UnitCell;
        UnitCellTravelled = UnitCellTravelled - SurfaceNormals(SurfaceNumber,:).*UnitCell;

    else
         Particle.Position = Particle.Position + Direction*CollidedDistance;
        Direction0 = Direction;
        angle = asin(-2*rand(1)+1); %% This is the diffuse reflection
        Direction = [sin(angle) -cos(angle)]; 
        RotAngle = atan2(SurfaceNormals(SurfaceNumber,1),-SurfaceNormals(SurfaceNumber,2));
        RotMatrix = [cos(RotAngle) -sin(RotAngle);sin(RotAngle) cos(RotAngle)];
        if SurfaceType(SurfaceNumber) == 1 %grain boundary
            if rand(1) < (1 - TransProb1)
                Direction = (RotMatrix*Direction')'*sign(-cosine(SurfaceNumber));
                %Direction =  Direction - 2*cosine(SurfaceNumber)*SurfaceNormals(SurfaceNumber,:);  %% This is the specular reflection 
            else
                Direction =Direction0;%does not change diretion if transmitted in grain boundary
            end
        else %pore/inclusion boundary
            if rand(1) < (1 - TransProb2)
                Direction = (RotMatrix*Direction')'*sign(-cosine(SurfaceNumber));
            else
                Direction =-(RotMatrix*Direction')'*sign(-cosine(SurfaceNumber)); %it does change direction
            end
        end
        CollisionNum(pp) = CollisionNum(pp) + 1;
    end

    end

  
    if UnitCellTravelled(1) < 0
        Trans(pp) = 0; 
    else
        Trans(pp) = 1;
    end
end
end

