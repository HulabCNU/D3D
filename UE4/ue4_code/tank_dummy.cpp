// Fill out your copyright notice in the Description page of Project Settings.


#include "tank_dummy.h"

// Sets default values
Atank_dummy::Atank_dummy()
{
	// Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;

	VisualMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Mesh"));
	VisualMesh->SetupAttachment(RootComponent);

	static ConstructorHelpers::FObjectFinder<UStaticMesh> CubeVisualAsset(TEXT("/Game/StarterContent/Shapes/Shape_QuadPyramid.Shape_QuadPyramid"));

	if (CubeVisualAsset.Succeeded())
	{
		VisualMesh->SetStaticMesh(CubeVisualAsset.Object);
		VisualMesh->SetRelativeLocation(FVector(0.0f, 0.0f, 0.0f));
		//VisualMesh->SetRelativeRotation(FVector(0.0f, 0.0f, 500.0f));
	}
}

// Called when the game starts or when spawned
void Atank_dummy::BeginPlay()
{
	Super::BeginPlay();
	//FVector NewLocation = GetActorLocation();
	//FRotator NewRotation;
	//NewRotation.Roll = 90;
	//SetActorLocationAndRotation(NewLocation, NewRotation);

	ifstream fp("transform_data.txt");

	string line;
	int im_counter = 0;
	while (getline(fp, line))
	{
		vector<double> data_line;
		string number;
		istringstream readstr(line);
		for (int j = 0; j < 7; j++) {
			getline(readstr, number, ',');
			data_line.push_back(atof(number.c_str()));
		}
		im_counter++;
		trans_vec.push_back(data_line);
	}
	GEngine->AddOnScreenDebugMessage(-1, 5.f, FColor::Green, FString::Printf(TEXT("Records : %d"), im_counter));
}

// Called every frame
void Atank_dummy::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	float RunningTime = GetGameTimeSinceCreation();
	int TimeIndex = int(5 * RunningTime) - 50;

	FVector NewLocation;
	FRotator NewRotation = GetActorRotation();

	GEngine->AddOnScreenDebugMessage(-1, 5.f, FColor::Green, FString::Printf(TEXT("Time [Record Duration] : %d [ %d ]"), TimeIndex, trans_vec.size()));
	int PoseIndex;
	PoseIndex = TimeIndex;
	if (PoseIndex > trans_vec.size() - 1)
	{
		PoseIndex = trans_vec.size() - 1;
	}
	if (PoseIndex < 0)
	{
		PoseIndex = 0;
	}
	NewLocation.X = 150 * trans_vec[PoseIndex][4];
	NewLocation.Y = 150 * trans_vec[PoseIndex][5];
	NewLocation.Z = 150 * trans_vec[PoseIndex][6];

	FQuat InputQuat;
	InputQuat.W = trans_vec[PoseIndex][0];
	InputQuat.X = trans_vec[PoseIndex][1];
	InputQuat.Y = trans_vec[PoseIndex][2];
	InputQuat.Z = trans_vec[PoseIndex][3];

	//float DeltaRotation = DeltaTime * 20.0f;    //Rotate by 20 degrees per second
	//NewRotation.Pitch -= DeltaRotation;
	//NewRotation.Roll = trans_vec[PoseIndex][2]*57.3;
	//NewRotation.Pitch = trans_vec[PoseIndex][1] * 57.3;
	//NewRotation.Yaw = trans_vec[PoseIndex][0] * 57.3;

	NewRotation = InputQuat.Rotator();
	//NewRotation.Roll -= 90;
	SetActorLocationAndRotation(NewLocation, NewRotation);
}

