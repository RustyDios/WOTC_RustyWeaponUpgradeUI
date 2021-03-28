//---------------------------------------------------------------------------------------
//  FILE:   UIArmory_WeaponUpgrade_Offset.uc                                    
//  
//	File created by RustyDios	27/03/20	12:00
//	LAST UPDATED				03/03/20	16:00
//
//	Adds an offset option to the weapon position in the UIArmory_WeaponUpgrade screen
//		Code inspired by Musashi's TacticalArmoryUI
//	Adressess CHL issues 39 and 832
//
//*******************************************************************************************

class UIArmory_WeaponUpgrade_Offset extends UIArmory_WeaponUpgrade config (UI);

/////////////////////////////////////////////////////////
// Added struct for offset position - Issue #832
struct WeaponViewOffset
{
	var name Template;
	var float offset_x;
	var float offset_y;
	var float offset_z;
};

// Added array to the UI config for offset positions - Issue #832
var config array<WeaponViewOffset> WeaponViewOffsets;

////////////////////////////////////
//	Rusty's fix for Issue #39
////////////////////////////////////

simulated function PreviewUpgrade(UIList ContainerList, int ItemIndex)
{
	local XComGameState_Item Weapon;
	local XComGameState ChangeState;
	local X2WeaponUpgradeTemplate UpgradeTemplate;
	local int WeaponAttachIndex, SlotIndex;
	local Name WeaponTemplateName;
	//local Vector PreviousLocation;
	//local Rotator PreviousRotation;

	if(ItemIndex == INDEX_NONE)
	{
		SetUpgradeText();
		return;
	}

	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Weapon_Attachement_Upgrade");
	ChangeState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Visualize Weapon Upgrade");

	Weapon = XComGameState_Item(ChangeState.ModifyStateObject(class'XComGameState_Item', WeaponRef.ObjectID));

	UpgradeTemplate = UIArmory_WeaponUpgradeItem(ContainerList.GetItem(ItemIndex)).UpgradeTemplate;
	SlotIndex = UIArmory_WeaponUpgradeItem(SlotsList.GetSelectedItem()).SlotIndex;

	Weapon.DeleteWeaponUpgradeTemplate(SlotIndex);
	if (UpgradeTemplate != none)
	{
		Weapon.ApplyWeaponUpgradeTemplate(UpgradeTemplate, SlotIndex);

		//Formulate the attachment specific location tag from the attach socket
		WeaponTemplateName = Weapon.GetMyTemplateName();
		for( WeaponAttachIndex = 0; WeaponAttachIndex < UpgradeTemplate.UpgradeAttachments.Length; ++WeaponAttachIndex )
		{
			if( UpgradeTemplate.UpgradeAttachments[WeaponAttachIndex].ApplyToWeaponTemplate == WeaponTemplateName &&
				UpgradeTemplate.UpgradeAttachments[WeaponAttachIndex].UIArmoryCameraPointTag != '' )
			{
				PawnLocationTag = UpgradeTemplate.UpgradeAttachments[WeaponAttachIndex].UIArmoryCameraPointTag;
				break;
			}
		}

		SetUpgradeText(UpgradeTemplate.GetItemFriendlyName(), UpgradeTemplate.GetItemBriefSummary());

		WeaponStats.PopulateData(Weapon, UpgradeTemplate);
	}

	if(ActiveList != UpgradesList)
	{
		//When we're not selecting an upgrade, let the user spin the weapon around
		MouseGuard.SetActorPawn(ActorPawn); 
		RestoreWeaponLocation();
	}
	else
	{
		//Otherwise, grab the rotation to show them the upgrade as they select it
		MouseGuard.SetActorPawn(None); 
	}

	// Start Issue #39

	//Remember to store the original position, location, rotation
	//PreviousLocation = ActorPawn.Location;
	//PreviousRotation = ActorPawn.Rotation;

	if(ActiveList != UpgradesList)
	{
		//if not selecting an upgrade revert to original behaviour, recall to reset the position, location and rotation
		RestoreWeaponLocation();
		CreateWeaponPawn(Weapon, ActorPawn.Rotation);
		ActorPawn.SetLocation(GetPlacementActor().Location);
		ActorPawn.SetRotation(GetPlacementActor().Rotation);
		MouseGuard.SetActorPawn(ActorPawn, ActorPawn.Rotation);
	}
	else
	{
		//an offshoot of the create weapon pawn function that respects the location tag set from the upgrade
		CreateWeaponPawnRespectUpgradeTag(Weapon, ActorPawn.Rotation, PawnLocationTag);
	}

	// End Issue #39

	`XCOMHISTORY.CleanupPendingGameState(ChangeState);
}

// copy of CreateWeaponPawn from UI_Armory that also feeds in any set PawnLocationTag from PreviewUpgrade RespectUpgradeTag
simulated function CreateWeaponPawnRespectUpgradeTag(XComGameState_Item Weapon, optional Rotator DesiredRotation, optional name RespectedPawnLocationTag)
{
	local Rotator NoneRotation;
	local XGWeapon WeaponVisualizer;
	
	// Make sure to clean up weapon actors left over from previous Armory screens.
	if(ActorPawn == none)
		ActorPawn = UIArmory(Movie.Stack.GetLastInstanceOf(class'UIArmory')).ActorPawn;

	// Clean up previous weapon actor
	//if( ActorPawn != none )
	//	ActorPawn.Destroy();

	WeaponVisualizer = XGWeapon(Weapon.GetVisualizer());
	if( WeaponVisualizer != none )
	{
		WeaponVisualizer.Destroy();
	}

	class'XGItem'.static.CreateVisualizer(Weapon);
	WeaponVisualizer = XGWeapon(Weapon.GetVisualizer());
	ActorPawn = WeaponVisualizer.GetEntity();

	// Start Issue #39

	//Set PawnLocationTag to any that was passed in
	PawnLocationTag = RespectedPawnLocationTag;

	//check PawnLocationTag and if empty set it to the weapon tag
	if (PawnLocationTag == '')
	{
		PawnLocationTag = X2WeaponTemplate(Weapon.GetMyTemplate()).UIArmoryCameraPointTag;

		//fallback to setting it to the cannon if the weapon doesn't have one set by the weapon template
		if (PawnLocationTag == '')
		{
			PawnLocationTag = 'UIPawnLocation_WeaponUpgrade_Cannon';
		}
	}

	// End Issue #39

	if(DesiredRotation == NoneRotation)
	{
		DesiredRotation = GetPlacementActor().Rotation;
	}

	ActorPawn.SetLocation(GetPlacementActor().Location);
	ActorPawn.SetRotation(DesiredRotation);
	ActorPawn.SetHidden(false);
}

////////////////////////////////////
//	Rusty's fix for Issue #832
////////////////////////////////////

function InterpolateWeapon()
{
	local Vector LocationLerp, GoalLocation;
	local Rotator RotatorLerp;
	local Quat StartRotation, GoalRotation, ResultRotation;
	local PointInSpace PlacementActor;

	// required for Issue #832
	local Vector BeginLocation, Offset;
	local XComGameState_Item Weapon;
	local int i;
	// end Issue #832

	PlacementActor = GetPlacementActor();

	GoalLocation = PlacementActor.Location;

	//this should fire to map the weapon pawn location to the screen by root bone
	if(PawnLocationTag != '')
	{
		//if the actor weapon isn't in the goal location move it there
		if(VSize(GoalLocation - ActorPawn.Location) > 0.1f)
		{
			LocationLerp = VLerp(ActorPawn.Location, GoalLocation, 0.1f);
			ActorPawn.SetLocation(LocationLerp);
		}

		// if MouseGuard is handling rotation of the weapon, stop rotating it here to prevent conflict
		if(MouseGuard.ActorPawn == none && ActiveList.SelectedIndex != -1 && UIArmory_WeaponUpgradeItem(ActiveList.GetSelectedItem()).UpgradeTemplate != none)
		{
			StartRotation = QuatFromRotator(ActorPawn.Rotation);
			GoalRotation = QuatFromRotator(PlacementActor.Rotation);
			ResultRotation = QuatSlerp(StartRotation, GoalRotation, 0.1f, true);
			RotatorLerp = QuatToRotator(ResultRotation);
			ActorPawn.SetRotation(RotatorLerp);
		}
	}

	// Start Issue #832

	// save the original position of the actor
	BeginLocation = ActorPawn.Location;

	//make sure we have got the right weapon details
	Weapon = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(WeaponRef.ObjectID));

	if (Weapon != none)
	{
		for (i=0 ; i <= default.WeaponViewOffsets.Length ; i++)
		{
			// Add an offset to the camera/root based on the weapon category ... this adjusts the weapons position on the screen
			if (Weapon.GetMyTemplateName() == default.WeaponViewOffsets[i].Template)
			{
				Offset.x = default.WeaponViewOffsets[i].offset_x;
				Offset.y = default.WeaponViewOffsets[i].offset_y;
				Offset.z = default.WeaponViewOffsets[i].offset_z;

				GoalLocation = BeginLocation + Offset;

				if(VSize(GoalLocation - ActorPawn.Location) > 0.1f)
				{
					LocationLerp = VLerp(ActorPawn.Location, GoalLocation, 0.1f);
					ActorPawn.SetLocation(LocationLerp);
				}
			}
		}
	}
	// End Issue #832
}
