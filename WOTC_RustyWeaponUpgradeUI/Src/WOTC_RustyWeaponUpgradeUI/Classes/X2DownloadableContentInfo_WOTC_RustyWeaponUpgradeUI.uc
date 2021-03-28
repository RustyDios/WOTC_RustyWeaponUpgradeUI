//*******************************************************************************************
//  FILE:   XComDownloadableContentInfo_WOTC_RustyWeaponUpgradeUI.uc                                    
//           
//	File created by RustyDios	31/03/20	09:00	
//	LAST UPDATED				31/03/20	11:30
//  
//	Ensures all weapons in the game have the things needed for the Weapon Upgrade UI
//
//*******************************************************************************************

class X2DownloadableContentInfo_WOTC_RustyWeaponUpgradeUI extends X2DownloadableContentInfo;

var config bool bDetailedRWU_UI_Log;

static event OnLoadedSavedGame(){}

static event InstallNewCampaign(XComGameState StartState){}

static event OnPostTemplatesCreated()
{
	local X2ItemTemplateManager				AllItems;			//holder for all items

	local array<X2DataTemplate>				AllWeapons;
	local X2DataTemplate					WeaponTemplate;
	local X2WeaponTemplate					CurrentWeapon;

	AllItems			= class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	//////////////////////////////////////////////////////////////////////////////////////////
	// Fix up any weapons missing the UI Armory Camera Point Tag
	//////////////////////////////////////////////////////////////////////////////////////////

	AllWeapons = AllItems.GetAllWeaponTemplates();
	foreach AllWeapons(WeaponTemplate)
	{
		CurrentWeapon = X2WeaponTemplate(WeaponTemplate);
			
		if (CurrentWeapon.WeaponPanelImage == "")
		{
			CurrentWeapon.WeaponPanelImage = "_ConventionalCannon";
		}

		if (CurrentWeapon.UIArmoryCameraPointTag == '')
		{
			CurrentWeapon.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Cannon';
		}

		`LOG("Patched :: "@CurrentWeapon.FriendlyName @" with UI Armory Weapon Upgrade details",default.bDetailedRWU_UI_Log,'WOTC_RustyWeaponUpgradeUI');
	}

	`LOG("Patched :: All Weapons NOW have Panel Image and Camera Point Tags",,'WOTC_RustyWeaponUpgradeUI');

	//////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////

} //END static event OnPostTemplatesCreated()
