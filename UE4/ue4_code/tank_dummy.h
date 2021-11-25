// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include <vector>
#include <fstream>
#include <string>
#include <sstream>
#include "Misc/Paths.h"
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "tank_dummy.generated.h"

using namespace std;

UCLASS()
class SOLIDTANK2_API Atank_dummy : public AActor
{
	GENERATED_BODY()
		UPROPERTY(VisibleAnywhere)
		UStaticMeshComponent* VisualMesh;

public:
	// Sets default values for this actor's properties
	Atank_dummy();
	vector<vector<double>> trans_vec;

protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;

public:
	// Called every frame
	virtual void Tick(float DeltaTime) override;

};
