-- Purpsose:                        Drops all the triggers created by makeTriggers.sql
DROP TRIGGER IF EXISTS unused_category;
DROP TRIGGER IF EXISTS auction_end_after_start;
DROP TRIGGER IF EXISTS raise_current_price;
DROP TRIGGER IF EXISTS user_bidder_match;
DROP TRIGGER IF EXISTS bids_time_match;
DROP TRIGGER IF EXISTS bids_in_auction_time;
DROP TRIGGER IF EXISTS number_of_bids;
DROP TRIGGER IF EXISTS new_bid_higher;
DROP TRIGGER IF EXISTS new_bid_current_time;
DROP TRIGGER IF EXISTS system_current_time;
DROP TRIGGER IF EXISTS now_time_one_row;