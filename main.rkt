#!/usr/bin/gracket

#lang racket

(require racket/gui)
(require "../mpdclient/obj-main.rkt")

(define mpd-frame
  (new
   (class frame%
	  (super-new)

	  ;;get mpd connection
	  (define mpd (new mpd-client%))
	  ;;TODO: check pass/fail
	  (send mpd create-connection)

	  (define menu-bar (new menu-bar% [parent this]))
	  (define menu-file (new menu% [parent menu-bar] [label "File"]))
	  (define menu-file-quit (new menu-item%
				      [parent menu-file]
				      [label "Exit"]
				      [callback (lambda (i e)
						  (send mpd close-connection)
						  (send mpd-frame show #f))]))
	  (define menu-tools (new menu% [parent menu-bar] [label "Tools"]))
	  (define menu-control (new menu% [parent menu-bar] [label "Control"]))
	  (define menu-help (new menu% [parent menu-bar] [label "Help"]))
	  
	  
	  ;; 1 stop button
	  ;; 2 previous button
	  ;; 3 play button
	  ;; 4 next button
	  ;; --
	  ;; 5 repeat
	  ;; 6 shuffle
	  (define display-panel (new horizontal-pane%
				     [parent this]
				     [alignment (list 'center 'top)]
				     [min-height 0]
				     [vert-margin 0]
				     [stretchable-height #f]))

	  
	  (define button-panel (new horizontal-pane%
				    [parent display-panel]))

	  (define bdims 75)
	  (define stop-button (new button%
				   [label "Stop"]
				   [parent button-panel]
				   [min-height bdims]
				   [min-width bdims]
				   [horiz-margin 0]
				   [callback
				    (lambda (b e)
				      (send mpd stop))]))
	  (define previous-button (new button%
				       [label "Previous"]
				       [parent button-panel]
				       [min-height bdims]
				       [min-width bdims]
				       [horiz-margin 0]
				       [callback
					(lambda (b e)
					  (send mpd previous))]))
	  (define pause-button (new button%
				   [label "Play/Pause"]
				   [parent button-panel]
				   [min-height bdims]
				   [min-width bdims]
				   [horiz-margin 0]
				   [callback
				    (lambda (b e)
				      (send mpd pause)
				      ;; (if (send mpd pause)
				      ;; 	  (send pause-button set-label "Pause")
				      ;; 	  #f)
				      )]))
	  (define next-button (new button%
				   [label "Next"]
				   [parent button-panel]
				   [min-height bdims]
				   [min-width bdims]
				   [horiz-margin 0]
				   [callback
				    (lambda (b e)
				      (send mpd next))]))
	  ;;vertical line
	  (define ops-panel (new horizontal-pane%
				 [parent button-panel]
				 [horiz-margin 8]))
	  (define repeat-button (new button%
				   [label "Repeat"]
				   [parent ops-panel]
				   [min-height bdims]
				   [min-width bdims]
				   [horiz-margin 0]
				   [callback
				    (lambda (b e)
				      (send mpd repeat 1))]))
	  (define shuffle-button (new button%
				   [label "Shuffle"]
				   [parent ops-panel]
				   [min-height bdims]
				   [min-width bdims]
				   [horiz-margin 0]
				   [callback
				    (lambda (b e)
				      (send mpd shuffle 1))]))
	  
	  (define status-panel (new horizontal-pane%
				    [parent display-panel]))
	  (define text (new message% [label "WEEEEE"] [parent status-panel]))
	  ;; 1 Artist
	  ;; 2 Album
	  ;; 3 Song
	  (define library-panel (new horizontal-pane%
				  [parent this]))
	  
	  (define artist-list (new list-box%
	  			   [label "Artists"]
	  			   [choices empty]
	  			   [parent library-panel]
	  			   [style (list 'multiple 'vertical-label)]
				   [vert-margin 0]
				   [horiz-margin 0]))
	  (define album-list (new list-box%
	  			  [label "Albums"]
	  			  [choices empty]
	  			  [parent library-panel]
	  			  [style (list 'multiple 'vertical-label)]
				  [vert-margin 0]
				  [horiz-margin 0]))
	  (define song-list (new list-box%
	  			 [label "Tracks"]
	  			 [choices empty]
	  			 [parent library-panel]
	  			 [style (list 'multiple 'vertical-label)]
				 [vert-margin 0]
				 [horiz-margin 0]))

	  	  ;; 2 Album
	  ;; 3 Song
	  (define playlist-panel (new horizontal-pane%
				  [parent this]))
	  (define playlist (new list-box%
			       [label "Library"]
			       [choices (list "Modest Mouse")]
			       [parent playlist-panel]
			       [style (list 'multiple 'vertical-label
					    'column-headers 'clickable-headers )]
			       [columns (list "Track" "Album" "Artist")]
			       [column-order (list 0 1 2)]
			       ;;sort by column
			       [callback (lambda (l e)
					   (displayln e))]))
	  );;end class def
   [label "RACKET MPD"]
   [width 800]
   [height 600]
   [alignment (list 'center 'top)]
   ));;end mpd frame

(send mpd-frame show #t)
(send mpd-frame center)

