

if exists(':HI') == 0
    runtime plugin/hih.vim
endif

let s:enable_italic=1


" target : 'fg' or 'bg'
" color : 
"      '#RRGGBB' for specifying a RGB color
"      '<color_name>' for using a color name
"      '@<hightlight_group>' for mimicing a group's color
function! hih#computeColor(color,target)
		if a:color ==# '-'
			return "NONE"
		endif

		if a:color =~ '^@'
			let linked_group = a:color[1:]
			let modif = matchstr(linked_group,'\v^[1-90a-zA-Z_]*\zs([\<\>].*)$')
			if ! empty(modif)
				let linked_group = matchstr(linked_group,'\v^([1-90a-zA-Z_]*)\ze([\<\>].*)$')
			endif

			let color_cterm=synIDattr(synIDtrans(hlID(linked_group)), a:target, 'cterm')
			let color_gui=synIDattr(synIDtrans(hlID(linked_group)), a:target, 'gui')

			let rgb_color = ''
			if color_gui != ''
				let rbg_color = color_gui[1:]
			elseif color_cterm != ''
				let rbg_color = s:cterm2gui(color_gui)
			endif

			if rgb_color != ''
				if ! empty(modif)
					let rgb_color = '#'.s:modify_color(color_gui[1:],modif)
				endif
			endif

			return '#' . rgb_color

		elseif a:color =~ '^#'
			return a:color
		endif

endfunction


function! hih#doHighlight(group, fg, bg, fx, ...)
		" execute 'highlight '.a:group.' guifg=#a0a0a0 ctermbg=18'
		" return

	let guic = ''
	let ctermc = ''

	if a:fg != '-'
		if s:isRGBColor(a:fg)
			let guic = a:fg
			let ctermc = hih#rgb2cterm(a:fg)
		else
			let guic = hih#cterm2gui(a:fg)
			let ctermc = a:fg
		endif
		execute 'highlight '.a:group.' guifg='.l:guic.' ctermfg='.l:ctermc
	endif

	if a:bg != '-'
		if s:isRGBColor(a:bg)
			let guic = a:bg
			let ctermc = hih#rgb2cterm(a:bg)
		else
			let guic = hih#cterm2gui(a:bg)
			let ctermc = a:bg
		endif
		execute 'highlight '.a:group.' guibg='.l:guic.' ctermbg='.l:ctermc
	endif

	if a:fx != '-'
		if a:fx =~ 'italic'
			if !s:enable_italic
				let ctfx = substitute(a:fx,'italic','bold','g')
				let gfx  = ctfx
			" elseif s:term_has_italic
				" let ctfx = a:fx
				" let gfx  = a:fx
			else
				let ctfx = substitute(a:fx,'italic','bold','g')
				let gfx  = a:fx
			endif
			execute 'highlight '.a:group.' term='.tfx.' cterm='.tfx.' gui='.gfx
		else
			execute 'highlight '.a:group.' term='.a:fx.' cterm='.a:fx.' gui='.a:fx
		endif
	endif

	" Any additional arguments are simply passed along
	if a:0
		execute 'highlight '.a:group.' '.join(a:000,' ')
	endif

	" call HIHSetColor(a:group,a:fg,'fg')

	" call HIHSetColor(a:group,a:bg,'bg')

	" if a:fx != '-'
	" 	let fx = a:fx
	" 	if fx =~ '^@'
	" 		" FIXME : find out 'cterm' value
	" 		let fx=synIDattr(synIDtrans(hlID(fx[1:])), '', 'cterm')
	" 	endif
	
	" 	if fx != ''
	" 	if fx =~ 'italic'
	" 		if g:hih_term_has_italic
	" 			let ctfx = fx
	" 			let gfx  = fx
	" 		else
	" 			let ctfx = substitute(fx,'italic','bold','g')
	" 			let gfx  = fx
	" 		endif
	" 		execute 'highlight '.a:group.' term='.ctfx.' cterm='.ctfx.' gui='.gfx
	" 	else
	" 		execute 'highlight '.a:group.' term='.fx.' cterm='.fx.' gui='.fx
	" 	endif
	" 	endif
	" endif

	" " Any additional arguments are simply passed along
	" if a:0
	" 	execute 'highlight '.a:group.' '.join(a:000,' ')
	" endif
endfunction

function! s:change_lightness(color,lightness)
	if a:lightness == 0
		return a:color
	endif

	let r = str2nr('0x'.a:color[0:1],16)
	let g = str2nr('0x'.a:color[2:3],16)
	let b = str2nr('0x'.a:color[4:5],16)

	if a:lightness > 0
		let r = r + ( 255 - r ) * a:lightness
		let g = g + ( 255 - g ) * a:lightness
		let b = b + ( 255 - b ) * a:lightness
	else
		let r = r * ( 1 + a:lightness )
		let g = g * ( 1 + a:lightness )
		let b = b * ( 1 + a:lightness )
	endif

	let r=  float2nr(r)
	let g = float2nr(g)
	let b = float2nr(b)

	if r > 255 | let r = 255 | elseif r < 0 | let r = 0 | endif	
	if g > 255 | let g = 255 | elseif g < 0 | let g = 0 | endif	
	if b > 255 | let b = 255 | elseif b < 0 | let b = 0 | endif	

	return printf("%02x", r)
		\ .printf("%02x", g)
		\ .printf("%02x", b)

endfunction

" @return a float from the 'value' parameter
" which can be
"   either a float
"   either a percentage (a number followed by '%')
function! s:percentOrRatio(value)
	if a:value =~ '.*%$'
		return str2float(a:value[:-2])/100
	else
		return str2float(a:value)
	endif
endfunction

function! s:modify_color(color,modification)
	if a:modification =~ '^>l=.*'
		let value = s:percentOrRatio(a:modification[3:])
		return s:change_lightness(a:color,value)
	endif

	if a:modification =~ '^<l=.*'
		let value = s:percentOrRatio(a:modification[3:])
		return s:change_lightness(a:color,-1*value)
	endif

	echohl ErrorMsg | echon "Unknown color modification '".a:modification."'" | echohl Normal
	return a:color
endfunction

function! hih#modif(color,modification)
	return s:modifyColor(a:color,a:modification)
endfunction






" """""""""""""""""""""""



function! hih#cterm2gui(color)
	if a:color =~ '[0123456789]\+'
		return '#'.s:xterm_colors[a:color]
	endif
	return a:color
endfunction

function! hih#rgb2cterm(color)

	let rgb_color = a:color
	if s:isRGBColor(a:color)
		let rgb_color = s:cleanRGBColor(a:color[1:])
	else
		throw "'".a:color."' is not a valid RGB color ( must match '^#?[a-fA-F01-9]{6}$')"
	endif

	let xterm_color = 0
	let previous_distance = 2.0*255*255*255

	let r_rgb = str2nr('0x'.rgb_color[0:1],16)
	let g_rgb = str2nr('0x'.rgb_color[2:3],16)
	let b_rgb = str2nr('0x'.rgb_color[4:5],16)
	
	
	let i = 0
	while i < 256

		let cterm_rgb_color = s:xterm_colors[''+i]

		if cterm_rgb_color ==? rgb_color
			return i
		endif

		let r_cterm = str2nr('0x'.cterm_rgb_color[0:1],16)
		let g_cterm = str2nr('0x'.cterm_rgb_color[2:3],16)
		let b_cterm = str2nr('0x'.cterm_rgb_color[4:5],16)
	
		let d  = ((r_rgb-r_cterm)*0.30)*((r_rgb-r_cterm)*0.30)
		    \  + ((g_rgb-g_cterm)*0.59)*((g_rgb-g_cterm)*0.59)
		    \  + ((b_rgb-b_cterm)*0.11)*((b_rgb-b_cterm)*0.11)

		if d < previous_distance
			let previous_distance = d
			let xterm_color = i
		endif

		let i = i+1

	endwhile

	return xterm_color
endfunction


function! s:isRGBColor(color)
	if a:color =~ '^#\?[a-fA-F01-9]\{6\}$'
		return 1
	elseif a:color =~ '^#[a-fA-F01-9]\{3,6\}$'
		return 1
	else
		return 0
	endif
endfunction
function! s:cleanRGBColor(color)
	let cc = a:color
	if a:color =~ '^#'
		let cc = a:color[1:]
	endif
	if len(cc) == 4 | return '00'.cc | endif
	if len(cc) == 5 | return '0'.cc | endif
	if len(cc) == 3 | return cc[0] . cc[0] . cc[1] . cc[1] .cc[2] . cc[2] | endif
	return cc
endfunction


" http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
let s:xterm_colors = {
	\ '0':   '000000', '1':   '800000', '2':   '008000', '3':   '808000', '4':   '000080',
	\ '5':   '800080', '6':   '008080', '7':   'c0c0c0', '8':   '808080', '9':   'ff0000',
	\ '10':  '00ff00', '11':  'ffff00', '12':  '0000ff', '13':  'ff00ff', '14':  '00ffff',
	\ '15':  'ffffff', '16':  '000000', '17':  '00005f', '18':  '000087', '19':  '0000af',
	\ '20':  '0000df', '21':  '0000ff', '22':  '005f00', '23':  '005f5f', '24':  '005f87',
	\ '25':  '005faf', '26':  '005fdf', '27':  '005fff', '28':  '008700', '29':  '00875f',
	\ '30':  '008787', '31':  '0087af', '32':  '0087df', '33':  '0087ff', '34':  '00af00',
	\ '35':  '00af5f', '36':  '00af87', '37':  '00afaf', '38':  '00afdf', '39':  '00afff',
	\ '40':  '00df00', '41':  '00df5f', '42':  '00df87', '43':  '00dfaf', '44':  '00dfdf',
	\ '45':  '00dfff', '46':  '00ff00', '47':  '00ff5f', '48':  '00ff87', '49':  '00ffaf',
	\ '50':  '00ffdf', '51':  '00ffff', '52':  '5f0000', '53':  '5f005f', '54':  '5f0087',
	\ '55':  '5f00af', '56':  '5f00df', '57':  '5f00ff', '58':  '5f5f00', '59':  '5f5f5f',
	\ '60':  '5f5f87', '61':  '5f5faf', '62':  '5f5fdf', '63':  '5f5fff', '64':  '5f8700',
	\ '65':  '5f875f', '66':  '5f8787', '67':  '5f87af', '68':  '5f87df', '69':  '5f87ff',
	\ '70':  '5faf00', '71':  '5faf5f', '72':  '5faf87', '73':  '5fafaf', '74':  '5fafdf',
	\ '75':  '5fafff', '76':  '5fdf00', '77':  '5fdf5f', '78':  '5fdf87', '79':  '5fdfaf',
	\ '80':  '5fdfdf', '81':  '5fdfff', '82':  '5fff00', '83':  '5fff5f', '84':  '5fff87',
	\ '85':  '5fffaf', '86':  '5fffdf', '87':  '5fffff', '88':  '870000', '89':  '87005f',
	\ '90':  '870087', '91':  '8700af', '92':  '8700df', '93':  '8700ff', '94':  '875f00',
	\ '95':  '875f5f', '96':  '875f87', '97':  '875faf', '98':  '875fdf', '99':  '875fff',
	\ '100': '878700', '101': '87875f', '102': '878787', '103': '8787af', '104': '8787df',
	\ '105': '8787ff', '106': '87af00', '107': '87af5f', '108': '87af87', '109': '87afaf',
	\ '110': '87afdf', '111': '87afff', '112': '87df00', '113': '87df5f', '114': '87df87',
	\ '115': '87dfaf', '116': '87dfdf', '117': '87dfff', '118': '87ff00', '119': '87ff5f',
	\ '120': '87ff87', '121': '87ffaf', '122': '87ffdf', '123': '87ffff', '124': 'af0000',
	\ '125': 'af005f', '126': 'af0087', '127': 'af00af', '128': 'af00df', '129': 'af00ff',
	\ '130': 'af5f00', '131': 'af5f5f', '132': 'af5f87', '133': 'af5faf', '134': 'af5fdf',
	\ '135': 'af5fff', '136': 'af8700', '137': 'af875f', '138': 'af8787', '139': 'af87af',
	\ '140': 'af87df', '141': 'af87ff', '142': 'afaf00', '143': 'afaf5f', '144': 'afaf87',
	\ '145': 'afafaf', '146': 'afafdf', '147': 'afafff', '148': 'afdf00', '149': 'afdf5f',
	\ '150': 'afdf87', '151': 'afdfaf', '152': 'afdfdf', '153': 'afdfff', '154': 'afff00',
	\ '155': 'afff5f', '156': 'afff87', '157': 'afffaf', '158': 'afffdf', '159': 'afffff',
	\ '160': 'df0000', '161': 'df005f', '162': 'df0087', '163': 'df00af', '164': 'df00df',
	\ '165': 'df00ff', '166': 'df5f00', '167': 'df5f5f', '168': 'df5f87', '169': 'df5faf',
	\ '170': 'df5fdf', '171': 'df5fff', '172': 'df8700', '173': 'df875f', '174': 'df8787',
	\ '175': 'df87af', '176': 'df87df', '177': 'df87ff', '178': 'dfaf00', '179': 'dfaf5f',
	\ '180': 'dfaf87', '181': 'dfafaf', '182': 'dfafdf', '183': 'dfafff', '184': 'dfdf00',
	\ '185': 'dfdf5f', '186': 'dfdf87', '187': 'dfdfaf', '188': 'dfdfdf', '189': 'dfdfff',
	\ '190': 'dfff00', '191': 'dfff5f', '192': 'dfff87', '193': 'dfffaf', '194': 'dfffdf',
	\ '195': 'dfffff', '196': 'ff0000', '197': 'ff005f', '198': 'ff0087', '199': 'ff00af',
	\ '200': 'ff00df', '201': 'ff00ff', '202': 'ff5f00', '203': 'ff5f5f', '204': 'ff5f87',
	\ '205': 'ff5faf', '206': 'ff5fdf', '207': 'ff5fff', '208': 'ff8700', '209': 'ff875f',
	\ '210': 'ff8787', '211': 'ff87af', '212': 'ff87df', '213': 'ff87ff', '214': 'ffaf00',
	\ '215': 'ffaf5f', '216': 'ffaf87', '217': 'ffafaf', '218': 'ffafdf', '219': 'ffafff',
	\ '220': 'ffdf00', '221': 'ffdf5f', '222': 'ffdf87', '223': 'ffdfaf', '224': 'ffdfdf',
	\ '225': 'ffdfff', '226': 'ffff00', '227': 'ffff5f', '228': 'ffff87', '229': 'ffffaf',
	\ '230': 'ffffdf', '231': 'ffffff', '232': '080808', '233': '121212', '234': '1c1c1c',
	\ '235': '262626', '236': '303030', '237': '3a3a3a', '238': '444444', '239': '4e4e4e',
	\ '240': '585858', '241': '606060', '242': '666666', '243': '767676', '244': '808080',
	\ '245': '8a8a8a', '246': '949494', '247': '9e9e9e', '248': 'a8a8a8', '249': 'b2b2b2',
	\ '250': 'bcbcbc', '251': 'c6c6c6', '252': 'd0d0d0', '253': 'dadada', '254': 'e4e4e4',
	\ '255': 'eeeeee', 'fg': 'fg', 'bg': 'bg', 'NONE': 'NONE' }

