#!/usr/bin/gracket

;; Racket Scheme MPD Gui Client
;;
;; Copyright 2012 Vincent Dumas 
;; Distributed under the GPLv3 license
;;

#lang racket/base

(require racket/gui/base racket/class racket/list srfi/13)
(require "../mpdclient/obj-main.rkt")

;;TODO: MPRIS2

(define mpd-frame
  (new
   (class frame%
	  (super-new)

	  ;;get mpd connection
	  (define mpd (new mpd-client%))
	  ;;TODO: check pass/fail
	  (send mpd create-connection)
	  ;; (define/public (mpd-connect)
	  ;;   (send mpd create-connection))
	  ;; (define/public (mpd-connect-args host port)
	  ;;   (send mpd create-connection host port))
	  
	  (define/override (on-exit)
	    (send mpd close)
	    (send mpd close-connection)
	    (send this show #f))


	  (define menu-bar (new menu-bar% [parent this]))
	  (define menu-file (new menu% [parent menu-bar] [label "File"]))
	  (define menu-file-read (new menu-item%
				      [parent menu-file]
				      [label "Read"]
				      [callback (lambda (i e)
						  (displayln
						   (send mpd fetch-response)))]))
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

	  ;; currently playing, time, album, artist
	  (define status-panel (new horizontal-pane%
				    [parent display-panel]))
	  
	  (define (get-status-msg hasht)
	    (if (> (hash-count hasht) 0)
		  (string-append (hash-ref hasht "Track") " "
				 (hash-ref hasht "Title") " "
				 (hash-ref hasht "Time") "\n"
				 (hash-ref hasht "Artist") " -- "
				 (hash-ref hasht "Album")) ""))
	  
	  (define text (new message%
			    [label (get-status-msg
				    (send mpd parse-response
					  (send mpd current-song)))]
			    [parent status-panel]))

	  ;; (define info (send mpd list-all-info))
	  ;; (displayln info)
	  ;; 1 Artist
	  ;; 2 Album
	  ;; 3 Song
	  (define library-panel (new horizontal-pane%
				  [parent this]))
	  (define artists (send mpd parse-response-list
				(send mpd mpd-list "artist")))
	  (define albums empty)
	  (define tracks empty)
	  
	  (define (handle-artist-click lb e)
	    ;;handle double click: add all albums/tracks
	    (update-albums (send lb get-string-selection)))
	  (define artist-list (new list-box%
	  			   [label "Artists"]
	  			   [choices artists]
	  			   [parent library-panel]
	  			   [style (list 'multiple 'vertical-label)]
				   [vert-margin 0]
				   [horiz-margin 0]
				   [callback handle-artist-click]))

	  (define (handle-album-click lb e)
	    ;;handle doubleclick: add all tracks from album
	    (if (equal? (send e get-event-type) 'list-box-dclick)
		(begin
		  (for-each
		   (lambda (el)
		     (send mpd add (hash-ref el "file")))
		   (send mpd parse-group "file"
			 (send mpd search "album"
			       (send album-list get-string-selection)
			       "artist"
			       (send artist-list get-string-selection)))))
		(begin
		  (update-tracks
		   (send lb get-string-selection)
		   (send artist-list get-string-selection)))))
	  (define album-list (new list-box%
	  			  [label "Albums"]
				  [choices albums]
	  			  [parent library-panel]
	  			  [style (list 'multiple 'vertical-label)]
				  [vert-margin 0]
				  [horiz-margin 0]
				  [callback handle-album-click]))
	  
	  (define (update-albums artist)
	    (set! albums (send mpd parse-response-list
			       (send mpd mpd-list "album" "artist" artist)))
	    (send album-list clear)
	    (send album-list set albums))

	  (update-albums (first artists))

	  (define (handle-song-click lb e)
	    ;;handle double click: add track
	    (when (equal? (send e get-event-type) 'list-box-dclick)
		  (let ([str 
			  (hash-ref
			   (first (send mpd parse-group "file"
				 (send mpd search "album"
				       (send album-list get-string-selection)
				       "artist"
				       (send artist-list get-string-selection)
				       "title"
				       (send lb get-string-selection)))) "file")])
		    (send mpd add str))))
	  
	  (define song-list (new list-box%
	  			 [label "Tracks"]
				 [choices tracks]
	  			 [parent library-panel]
	  			 [style (list 'multiple 'vertical-label)]
				 [columns (list "Track" "Title")]
				 [vert-margin 0]
				 [horiz-margin 0]
				 [callback handle-song-click]))
	  ;;add shit
	  (define (update-tracks album artist)
	    (set! tracks (send mpd parse-group "file"
			       (send mpd search "album" album "artist" artist)))
	    (send song-list clear)
	    (let ([count 0])
	      (for-each (lambda (t)
			  (send song-list append (hash-ref t "Track"))
			  (send song-list set-string count
				(hash-ref t "Title") 1)
			  (set! count (+ count 1))) tracks)))
	  (update-tracks (first albums) (first artists))
	  
	  ;; 2 Album
	  ;; 3 Song
	  ;;set-column-width
	  (define playlist-panel (new horizontal-pane%
				      [parent this]))
	  (define playlist empty)
	  (define playlist-box (new list-box%
				    [label "Playlist"]
				    ;;get playlist
				    [choices playlist]
				    [parent playlist-panel]
				    [style (list 'multiple 'vertical-label
						 'column-headers 'clickable-headers )]
				    [columns (list "Track" "Title" "Album"
						   "Artist" "Time" "Genre"
						   "Date")]
				    ;;sort by column
				    [callback (lambda (l e)
						;;TODO: finish
						(displayln e))]))
	  
	  
	  (define (update-playlist)
	    (define count 0)
	    (for-each
	     (lambda (ht)
	       (define-values (mins secs) (quotient/remainder
					   (string->number
					    (hash-ref! ht "Time" "")) 60))
	       (send playlist-box append (hash-ref! ht "Track" ""))
	       (send playlist-box set-string count (hash-ref! ht "Title" "") 1)
	       (send playlist-box set-string count (hash-ref! ht "Album" "") 2)
	       (send playlist-box set-string count (hash-ref! ht "Artist" "") 3)
	       (send playlist-box set-string count
		     (string-append
		      (number->string mins) "m "
		      (string-pad (number->string secs) 2 #\0) "s") 4)
	       (send playlist-box set-string count (hash-ref! ht "Genre" "") 5)
	       (send playlist-box set-string count (hash-ref! ht "Date" "") 6)
	       (set! count (+ count 1)))
	     (send mpd parse-group "file"
		   (send mpd playlist-info))))
	  
	  (update-playlist)
	  
	  ;;default column widths
	  (send playlist-box set-column-width 0 50 5 300)
	  (send playlist-box set-column-width 1 175 5 300)
	  (send playlist-box set-column-width 2 175 5 300)
	  (send playlist-box set-column-width 3 175 5 300)
	  (send playlist-box set-column-width 4 100 5 300)
	  (send playlist-box set-column-width 5 100 5 300)
	  (send playlist-box set-column-width 6 50 5 300)
	  
	  );;end class def
   [label "RACKET MPD"]
   [width 800]
   [height 600]
   [alignment (list 'center 'top)]
   ));;end mpd frame

(send mpd-frame show #t)
(send mpd-frame center)
;;(send mpd-frame mpd-connect)

