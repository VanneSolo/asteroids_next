--[[

	Options du jeu. A terme, il devrait être possible de:
	- joueur à un ou deux joueurs.
	- choisir de quel côté du terrain on veut jouer.
	- afficher le terrain verticalement ou horizontalement.
	- choisir le niveau de difficulté.
	- choisir le type de victoire (points ou temps)
	- modifier le volume des effets sonores.
	- modifier le volume des musiques.
	
	Les options elles-mêmes seront situées dans le fichier
	options_asset. Depuis le menu on pourra accéder à toutes
	les options mais seulement certaines seront accessibles
	depuis le jeu.
	
	On accède ici uniquement depuis le menu et on ne peut
	retourner qu'au menu.

]]
local bouton_nb_joueurs
local bouton_orientation_terrain
local bouton_choix_cote_j1
local bouton_type_victoire
local bouton_niveau_difficulte

local bouton_un_joueur
local bouton_deux_joueurs
local bouton_vertical
local bouton_horizontal
local bouton_choix_cote_un
local bouton_choix_cote_deux
local bouton_temps
local bouton_score
local bouton_diff_level_un
local bouton_diff_level_deux
local bouton_diff_level_trois

local info_options
local info_nb_joueurs
local info_orientation_terrain
local info_choix_cote_j1
local info_type_victoire
local info_niveau_difficulte

local texte_nb_joueur
local texte_orientation_terrain
local texte_choix_cote_j1
local texte_type_victoire
local texte_niveau_difficulte

Load_Bouton_Option_Idle()
Load_Bouton_Option_Survole()
Load_Bouton_Option_Clique()

Load_Bouton_Option_Child_Idle()
Load_Bouton_Option_Child_Survole()
Load_Bouton_Option_Child_Clique()

interface_bouton_idle = sprite_bouton_option_idle.img
interface_bouton_survole = sprite_bouton_option_survole.img
interface_bouton_clique = sprite_bouton_option_clique.img

interface_child_bouton_idle = sprite_bouton_option_child_idle.img
interface_child_bouton_survole = sprite_bouton_option_child_survole.img
interface_child_bouton_clique = sprite_bouton_option_child_clique.img

local function On_M_Options_Panel_Hover(p_state)
  if p_state == "begin" then
    if bouton_nb_joueurs.is_hover then
      info_nb_joueurs:Set_Visible(true)
    elseif bouton_orientation_terrain.is_hover then
      info_orientation_terrain:Set_Visible(true)
    elseif bouton_choix_cote_j1.is_hover then
      info_choix_cote_j1:Set_Visible(true)
    elseif bouton_type_victoire.is_hover then
      info_type_victoire:Set_Visible(true)
    elseif bouton_niveau_difficulte.is_hover then
      info_niveau_difficulte:Set_Visible(true)
    end
  elseif p_state == "end" then
    info_nb_joueurs:Set_Visible(false)
    info_orientation_terrain:Set_Visible(false)
    info_choix_cote_j1:Set_Visible(false)
    info_type_victoire:Set_Visible(false)
    info_niveau_difficulte:Set_Visible(false)
  end
end

local function On_M_Options_Button_Clicked(p_state)
  if p_state == "begin" then
    
  elseif p_state == "end" then
    if bouton_vertical.is_hover and bouton_vertical.is_pressed == false then
      options_assets.orientation = "vertical"
      options_assets.side = "haut"
      --bouton_haut.texte = "H"
      --bouton_bas.texte = "B"
    elseif bouton_horizontal.is_hover and bouton_horizontal.is_pressed == false then
      options_assets.orientation = "horizontal"
      options_assets.side = "gauche"
      --bouton_haut.texte = "G"
      --bouton_bas.texte = "D"
    elseif bouton_choix_cote_un.is_hover and bouton_choix_cote_un.is_pressed == false then
      print(bouton_choix_cote_un.texte)
      if bouton_choix_cote_un.texte == "G" then
        options_assets.side = "gauche"
      elseif bouton_choix_cote_un.texte == "H" then
        options_assets.side = "haut"
      end
    elseif bouton_choix_cote_deux.is_hover and bouton_choix_cote_deux.is_pressed == false then
      print(bouton_choix_cote_deux.texte)
      if bouton_choix_cote_deux.texte == "D" then
        options_assets.side = "droite"
      elseif bouton_choix_cote_deux.texte == "B" then
        options_assets.side = "bas"
      end
    end
  end
end

local Options_Manager = {}
local options_ui = gui.New()
start_x = 50
start_y = 50
panel_w = 250
panel_h = 35
button_w = 35
button_h = panel_h
space_beetween_panel = 20
space_from_panel = 40
space_beetween_button = 20

-- Panneau sur lequel on affiche des infos sur le bouton survolé.
info_options = gui.New_Panel(550, 50, 200, 100, vert)

-- Choisir le nombre de joueur(s).
bouton_nb_joueurs = gui.New_Panel(start_x, start_y, panel_w, panel_h, blanc)
bouton_nb_joueurs:Set_Event("hover", On_M_Options_Panel_Hover)
texte_nb_joueur = gui.New_Text(bouton_nb_joueurs.x, bouton_nb_joueurs.y, bouton_nb_joueurs.w, bouton_nb_joueurs.h, "Nombre de joueur(s)", font_2, "center", "center", blanc)
info_nb_joueurs = gui.New_Text(info_options.x, info_options.y, info_options.w, info_options.h, "un ou deux joueurs", font_2, "center", "center", rouge)
info_nb_joueurs:Set_Visible(false)

bouton_un_joueur = gui.New_Button(bouton_nb_joueurs.x+bouton_nb_joueurs.w+space_from_panel, bouton_nb_joueurs.y, button_w, button_h, "1", font_2, blanc)
bouton_un_joueur:Set_Event("hover", On_M_Options_Panel_Hover)
bouton_un_joueur:Set_Event("pressed", On_M_Options_Button_Clicked)

bouton_deux_joueurs = gui.New_Button(bouton_un_joueur.x+bouton_un_joueur.w+space_beetween_button, bouton_nb_joueurs.y, button_w, button_h, "2", font_2, blanc)
bouton_deux_joueurs:Set_Event("hover", On_M_Options_Panel_Hover)
bouton_deux_joueurs:Set_Event("pressed", On_M_Options_Button_Clicked)

-- Choisir l'orientation du terrain.
bouton_orientation_terrain = gui.New_Panel(start_x, bouton_nb_joueurs.y+bouton_nb_joueurs.h+space_beetween_panel, panel_w, panel_h, blanc)
bouton_orientation_terrain:Set_Event("hover", On_M_Options_Panel_Hover)
texte_orientation_terrain = gui.New_Text(bouton_orientation_terrain.x, bouton_orientation_terrain.y, bouton_orientation_terrain.w, bouton_orientation_terrain.h, "Orientation du terrain", font_2, "center", "center", blanc)
info_orientation_terrain = gui.New_Text(info_options.x, info_options.y, info_options.w, info_options.h, "terrain _ ou |", font_2, "center", "center", rouge)
info_orientation_terrain:Set_Visible(false)

bouton_vertical = gui.New_Button(bouton_orientation_terrain.x+bouton_orientation_terrain.w+space_from_panel, bouton_orientation_terrain.y, button_w, button_h, "V", font_2, blanc)
bouton_vertical:Set_Event("hover", On_M_Options_Panel_Hover)
bouton_vertical:Set_Event("pressed", On_M_Options_Button_Clicked)

bouton_horizontal = gui.New_Button(bouton_vertical.x+bouton_vertical.w+space_beetween_button, bouton_orientation_terrain.y, button_w, button_h, "H", font_2, blanc)
bouton_horizontal:Set_Event("hover", On_M_Options_Panel_Hover)
bouton_horizontal:Set_Event("pressed", On_M_Options_Button_Clicked)

-- Choisir le côté du joueur un.
bouton_choix_cote_j1 = gui.New_Panel(start_x, bouton_orientation_terrain.y+bouton_orientation_terrain.h+space_beetween_panel, panel_w, panel_h, blanc)
bouton_choix_cote_j1:Set_Event("hover", On_M_Options_Panel_Hover)
texte_choix_cote_j1 = gui.New_Text(bouton_choix_cote_j1.x, bouton_choix_cote_j1.y, bouton_choix_cote_j1.w, bouton_choix_cote_j1.h, "Choix du coté", font_2, "center", "center", blanc)
info_choix_cote_j1 = gui.New_Text(info_options.x, info_options.y, info_options.w, info_options.h, "j1: gauche ou droite, haut ou bas", font_2, "center", "center", rouge)
info_choix_cote_j1:Set_Visible(false)

bouton_choix_cote_un = gui.New_Button(bouton_choix_cote_j1.x+bouton_choix_cote_j1.w+space_from_panel, bouton_choix_cote_j1.y, button_w, button_h, "G", font_2, blanc)
bouton_choix_cote_un:Set_Event("hover", On_M_Options_Panel_Hover)
bouton_choix_cote_un:Set_Event("pressed", On_M_Options_Button_Clicked)

bouton_choix_cote_deux = gui.New_Button(bouton_choix_cote_un.x+bouton_choix_cote_un.w+space_beetween_button, bouton_choix_cote_j1.y, button_w, button_h, "D", font_2, blanc)
bouton_choix_cote_deux:Set_Event("hover", On_M_Options_Panel_Hover)
bouton_choix_cote_deux:Set_Event("pressed", On_M_Options_Button_Clicked)

-- Choisir le type de victoire.
bouton_type_victoire = gui.New_Panel(start_x, bouton_choix_cote_j1.y+bouton_choix_cote_j1.h+space_beetween_panel, panel_w, panel_h, blanc)
bouton_type_victoire:Set_Event("hover", On_M_Options_Panel_Hover)
texte_type_victoire = gui.New_Text(bouton_type_victoire.x, bouton_type_victoire.y, bouton_type_victoire.w, bouton_type_victoire.h, "Type de victoire", font_2, "center", "center", blanc)
info_type_victoire = gui.New_Text(info_options.x, info_options.y, info_options.w, info_options.h, "victoire au temps ou au score", font_2, "center", "center", rouge)
info_type_victoire:Set_Visible(false)

bouton_temps = gui.New_Button(bouton_type_victoire.x+bouton_type_victoire.w+space_from_panel, bouton_type_victoire.y, button_w, button_h, "T", font_2, blanc)
bouton_temps:Set_Event("hover", On_M_Options_Panel_Hover)
bouton_temps:Set_Event("pressed", On_M_Options_Button_Clicked)

bouton_score = gui.New_Button(bouton_temps.x+bouton_temps.w+space_beetween_button, bouton_type_victoire.y, button_w, button_h, "S", font_2, blanc)
bouton_score:Set_Event("hover", On_M_Options_Panel_Hover)
bouton_score:Set_Event("pressed", On_M_Options_Button_Clicked)

-- Choisir le niveau de difficulté.
bouton_niveau_difficulte = gui.New_Panel(start_x, bouton_type_victoire.y+bouton_type_victoire.h+space_beetween_panel, panel_w, panel_h, blanc)
bouton_niveau_difficulte:Set_Event("hover", On_M_Options_Panel_Hover)
texte_niveau_difficulte = gui.New_Text(bouton_niveau_difficulte.x, bouton_niveau_difficulte.y, bouton_niveau_difficulte.w, bouton_niveau_difficulte.h, "Niveau de difficulte", font_2, "center", "center", blanc)
info_niveau_difficulte = gui.New_Text(info_options.x, info_options.y, info_options.w, info_options.h, "choix de la difficulte", font_2, "center", "center", rouge)
info_niveau_difficulte:Set_Visible(false)

bouton_diff_level_un = gui.New_Button(bouton_niveau_difficulte.x+bouton_niveau_difficulte.w+space_from_panel, bouton_niveau_difficulte.y, button_w, button_h, "1", font_2, blanc)
bouton_diff_level_un:Set_Event("hover", On_M_Options_Panel_Hover)
bouton_diff_level_un:Set_Event("pressed", On_M_Options_Button_Clicked)

bouton_diff_level_deux = gui.New_Button(bouton_diff_level_un.x+bouton_diff_level_un.w+space_beetween_button, bouton_niveau_difficulte.y, button_w, button_h, "2", font_2, blanc)
bouton_diff_level_deux:Set_Event("hover", On_M_Options_Panel_Hover)
bouton_diff_level_deux:Set_Event("pressed", On_M_Options_Button_Clicked)

bouton_diff_level_trois = gui.New_Button(bouton_diff_level_deux.x+bouton_diff_level_deux.w+space_beetween_button, bouton_niveau_difficulte.y, button_w, button_h, "3", font_2, blanc)
bouton_diff_level_trois:Set_Event("hover", On_M_Options_Panel_Hover)
bouton_diff_level_trois:Set_Event("pressed", On_M_Options_Button_Clicked)

-- Ajouter tous les éléments dans l'ui.
options_ui = gui.New()
options_ui:Add_Element(bouton_nb_joueurs)
options_ui:Add_Element(bouton_un_joueur)
options_ui:Add_Element(bouton_deux_joueurs)

options_ui:Add_Element(bouton_orientation_terrain)
options_ui:Add_Element(bouton_vertical)
options_ui:Add_Element(bouton_horizontal)

options_ui:Add_Element(bouton_choix_cote_j1)
options_ui:Add_Element(bouton_choix_cote_un)
options_ui:Add_Element(bouton_choix_cote_deux)

options_ui:Add_Element(bouton_type_victoire)
options_ui:Add_Element(bouton_temps)
options_ui:Add_Element(bouton_score)

options_ui:Add_Element(bouton_niveau_difficulte)
options_ui:Add_Element(bouton_diff_level_un)
options_ui:Add_Element(bouton_diff_level_deux)
options_ui:Add_Element(bouton_diff_level_trois)

options_ui:Add_Element(info_options)
options_ui:Add_Element(info_nb_joueurs)
options_ui:Add_Element(info_orientation_terrain)
options_ui:Add_Element(info_choix_cote_j1)
options_ui:Add_Element(info_type_victoire)
options_ui:Add_Element(info_niveau_difficulte)

options_ui:Add_Element(texte_nb_joueur)
options_ui:Add_Element(texte_orientation_terrain)
options_ui:Add_Element(texte_choix_cote_j1)
options_ui:Add_Element(texte_type_victoire)
options_ui:Add_Element(texte_niveau_difficulte)

function Options_Manager:Update(dt)
  if options_assets.orientation == "vertical" then
    bouton_choix_cote_un.texte = "H"
    bouton_choix_cote_deux.texte = "B"
    --print(bouton_gauche, bouton_droite, bouton_haut.texte, bouton_bas.texte)
  elseif options_assets.orientation == "horizontal" then
    bouton_choix_cote_un.texte = "G"
    bouton_choix_cote_deux.texte = "D"
    --print(bouton_gauche, bouton_droite, bouton_haut.texte, bouton_bas.texte)
  end
  
	options_ui:Update(dt)
end

function Options_Manager:Draw()
  love.graphics.print(options_assets.orientation, 5, 5)
  options_ui:Draw()
end

function Options_Manager:Keypressed(key)
  if key == "backspace" then
    Game.current_state = "menu"
  end
end

function Options_Manager:Mousepressed(x, y, button)
  
end

return Options_Manager