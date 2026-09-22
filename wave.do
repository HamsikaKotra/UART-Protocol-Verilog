onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /uart_tb/clk
add wave -noupdate -radix binary /uart_tb/rst
add wave -noupdate -radix binary /uart_tb/tx_start
add wave -noupdate -radix binary /uart_tb/tx_data
add wave -noupdate -radix binary /uart_tb/tx_line
add wave -noupdate -radix binary /uart_tb/tx_busy
add wave -noupdate -radix binary /uart_tb/rx_done
add wave -noupdate -radix binary /uart_tb/rx_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2520252 ns}
