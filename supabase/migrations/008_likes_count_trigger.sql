-- Migration 008: Auto-increment/decrement likes_count on photos table
-- Triggered by INSERT/DELETE on likes table

CREATE OR REPLACE FUNCTION update_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE photos 
    SET likes_count = COALESCE(likes_count, 0) + 1
    WHERE id = NEW.photo_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE photos 
    SET likes_count = GREATEST(COALESCE(likes_count, 0) - 1, 0)
    WHERE id = OLD.photo_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_update_likes_count ON likes;

CREATE TRIGGER trigger_update_likes_count
  AFTER INSERT OR DELETE ON likes
  FOR EACH ROW
  EXECUTE FUNCTION update_likes_count();
